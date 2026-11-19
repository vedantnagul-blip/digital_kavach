const crypto = require("node:crypto");

const {onCall, HttpsError} = require("firebase-functions/v2/https");
const {initializeApp} = require("firebase-admin/app");
const {
  getFirestore,
  FieldValue,
  Timestamp,
} = require("firebase-admin/firestore");

initializeApp();

const db = getFirestore();

// Pairing settings.
const CODE_LENGTH = 6;
const CODE_ALPHABET = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789";
const INVITE_DURATION_MS = 15 * 60 * 1000;
const MAX_ATTEMPTS = 5;


/**
  * Generate a cryptographically random pairing code.
  * @return {string} The generated pairing code.
  */
function generateCode() {
  let code = "";

  for (let i = 0; i < CODE_LENGTH; i++) {
    const index = crypto.randomInt(CODE_ALPHABET.length);
    code += CODE_ALPHABET[index];
  }

  return code;
}

/**
 * Hash a pairing code before storing it.
 * The invite document must not be readable by clients.
 * @param {string} code The pairing code to hash.
 * @return {string} The SHA-256 hash of the code.
 */
function hashCode(code) {
  return crypto
      .createHash("sha256")
      .update(code.toUpperCase())
      .digest("hex");
}
/**
 * Check that the caller is signed in.
 * @param {object} request The callable function request.
 * @return {string} The signed-in user's UID.
 */
function requireSignedIn(request) {
  if (!request.auth) {
    throw new HttpsError(
        "unauthenticated",
        "Sign in before using Family Shield.",
    );
  }

  return request.auth.uid;
}

/**
 * Create a family, or create a new invitation for an existing family.
 *
 * Only an existing guardian can create another invitation for that family.
 */
exports.createFamilyInvite = onCall(async (request) => {
  const uid = requireSignedIn(request);

  const code = generateCode();
  const codeHash = hashCode(code);
  const expiresAtMs = Date.now() + INVITE_DURATION_MS;

  const userRef = db.collection("users").doc(uid);

  // This ID is used only if the user does not already have a family.
  const newFamilyRef = db.collection("families").doc();

  const result = await db.runTransaction(async (transaction) => {
    const userSnapshot = await transaction.get(userRef);
    const userData = userSnapshot.exists ? userSnapshot.data() : {};

    const existingFamilyId = userData.familyId;

    let familyRef;
    let familySnapshot = null;

    if (existingFamilyId) {
      familyRef = db.collection("families").doc(existingFamilyId);
      familySnapshot = await transaction.get(familyRef);

      if (!familySnapshot.exists) {
        throw new HttpsError(
            "failed-precondition",
            "Your existing family could not be found.",
        );
      }

      const family = familySnapshot.data();
      const guardians = Array.isArray(family.guardianUids) ?
        family.guardianUids :
        [];

      if (!guardians.includes(uid)) {
        throw new HttpsError(
            "permission-denied",
            "Only a family guardian can create an invitation.",
        );
      }
    } else {
      familyRef = newFamilyRef;
    }

    const inviteRef = db.collection("familyInvites").doc(familyRef.id);

    // All reads above are completed before transaction writes.
    if (!existingFamilyId) {
      transaction.create(familyRef, {
        guardianUids: [uid],
        elderUids: [],
        status: "pending",
        createdAt: FieldValue.serverTimestamp(),
      });

      transaction.set(
          userRef,
          {familyId: familyRef.id},
          {merge: true},
      );
    }

    // Replacing this document invalidates the previous invitation.
    transaction.set(inviteRef, {
      familyId: familyRef.id,
      codeHash,
      createdBy: uid,
      attempts: 0,
      expiresAt: Timestamp.fromMillis(expiresAtMs),
      createdAt: FieldValue.serverTimestamp(),
    });

    return familyRef.id;
  });

  return {
    familyId: result,
    pairCode: code,
    expiresAt: expiresAtMs,
  };
});

/**
 * Verify an invitation and add the signed-in user as an elder member.
 */
exports.joinFamilyWithInvite = onCall(async (request) => {
  const uid = requireSignedIn(request);

  const familyId =
    typeof request.data?.familyId === "string" ?
      request.data.familyId.trim() :
      "";

  const pairCode =
    typeof request.data?.pairCode === "string" ?
      request.data.pairCode.trim().toUpperCase() :
      "";

  // Firestore-generated document IDs do not contain slashes.
  if (
    !familyId ||
    familyId.length > 100 ||
    familyId.includes("/") ||
    !/^[A-HJ-NP-Z2-9]{6}$/.test(pairCode)
  ) {
    throw new HttpsError(
        "invalid-argument",
        "Enter a valid Family ID and six-character code.",
    );
  }

  const familyRef = db.collection("families").doc(familyId);
  const inviteRef = db.collection("familyInvites").doc(familyId);
  const userRef = db.collection("users").doc(uid);

  const result = await db.runTransaction(async (transaction) => {
    const [familySnapshot, inviteSnapshot, userSnapshot] =
      await Promise.all([
        transaction.get(familyRef),
        transaction.get(inviteRef),
        transaction.get(userRef),
      ]);

    if (!familySnapshot.exists || !inviteSnapshot.exists) {
      return {status: "invalid"};
    }

    const family = familySnapshot.data();
    const invite = inviteSnapshot.data();
    const userData = userSnapshot.exists ? userSnapshot.data() : {};

    const expiresAtMs = invite.expiresAt?.toMillis?.() ?? 0;
    const attempts = Number(invite.attempts ?? 0);

    if (expiresAtMs <= Date.now()) {
      return {status: "expired"};
    }

    if (attempts >= MAX_ATTEMPTS) {
      return {status: "locked"};
    }

    if (invite.codeHash !== hashCode(pairCode)) {
      // Return instead of throwing inside the transaction so the attempt
      // counter is committed.
      transaction.update(inviteRef, {
        attempts: attempts + 1,
      });

      return {status: "invalid"};
    }

    const guardians = Array.isArray(family.guardianUids) ?
      family.guardianUids :
      [];

    const elders = Array.isArray(family.elderUids) ?
      family.elderUids :
      [];

    if (guardians.includes(uid)) {
      return {status: "self-pair"};
    }

    if (elders.includes(uid)) {
      return {status: "already-member"};
    }

    if (userData.familyId && userData.familyId !== familyId) {
      return {status: "other-family"};
    }

    transaction.update(familyRef, {
      elderUids: FieldValue.arrayUnion(uid),
      status: "active",
      updatedAt: FieldValue.serverTimestamp(),
    });

    transaction.set(
        userRef,
        {familyId},
        {merge: true},
    );

    // Single-use invitation.
    transaction.delete(inviteRef);

    return {status: "joined"};
  });

  switch (result.status) {
    case "joined":
      return {success: true};

    case "expired":
      throw new HttpsError(
          "deadline-exceeded",
          "The pairing invitation has expired.",
      );

    case "locked":
      throw new HttpsError(
          "resource-exhausted",
          "Too many attempts. Ask the guardian for a new invitation.",
      );

    case "self-pair":
      throw new HttpsError(
          "failed-precondition",
          "You cannot join your own family as the elder.",
      );

    case "already-member":
      throw new HttpsError(
          "already-exists",
          "You are already a member of this family.",
      );

    case "other-family":
      throw new HttpsError(
          "failed-precondition",
          "This account already belongs to another family.",
      );

    default:
      throw new HttpsError(
          "permission-denied",
          "The Family ID or pairing code is invalid.",
      );
  }
});

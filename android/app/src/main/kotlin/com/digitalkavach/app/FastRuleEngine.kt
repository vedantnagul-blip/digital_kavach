package com.digitalkavach.app

/**
 * Mirror of 12 highest-signal rules from `assets/rules.json`.
 *
 * ⚠️ IMPORTANT: Rule IDs and patterns MUST match rules.json exactly.
 * If rules.json changes any of these, regenerate this file.
 *
 * Mirrored rule IDs (12 total):
 *   1.  r_digital_arrest_01
 *   2.  r_digital_arrest_02 (Hindi)
 *   3.  r_fake_kyc_01
 *   4.  r_fake_kyc_02 (Hindi)
 *   5.  r_upi_collect_01
 *   6.  r_upi_pin_receive
 *   7.  r_fake_challan_02 (govt allowlist)
 *   8.  r_lottery_01
 *   9.  r_lottery_02
 *   10. r_phishing_link_02 (suspicious TLD)
 *   11. r_qr_impersonation_01
 *   12. r_urgency_01
 */
object FastRuleEngine {
    data class Hit(
        val ruleId: String,
        val family: String,
        val weight: Int,
        val snippet: String
    )

    data class Result(
        val score: Int,
        val hits: List<Hit>,
        val topFamily: String
    )

    private val rules = listOf(
        Rule(
            "r_digital_arrest_01", "digital_arrest", 60,
            Regex("digital\\s*arrest|CBI.{0,20}officer|customs.{0,30}parcel|arrest\\s+warrant|court\\s+summon", RegexOption.IGNORE_CASE)
        ),
        Rule(
            "r_digital_arrest_02", "digital_arrest", 60,
            Regex("डिजिटल\\s*अरेस्ट|गिरफ़्तारी\\s*वारंट|सीबीआई\\s*अधिकारी|कस्टम.{0,30}पार्सल", RegexOption.IGNORE_CASE)
        ),
        Rule(
            "r_fake_kyc_01", "fake_kyc", 45,
            Regex("kyc\\s*(expired|suspend|blocked|update|verify|pending)", RegexOption.IGNORE_CASE)
        ),
        Rule(
            "r_fake_kyc_02", "fake_kyc", 45,
            Regex("kyc\\s*(अवधि\\s*समाप्त|समाप्त|अपडेट|बंद|पूरी\\s*करें)|केवायसी", RegexOption.IGNORE_CASE)
        ),
        Rule(
            "r_upi_collect_01", "upi_collect_trap", 55,
            Regex("(pin.{0,40}(receive|get\\s*money|पैसे\\s*पाने|मिळवण्यासाठी|प्राप्त))|((receive|get\\s*money|पैसे\\s*पाने).{0,40}pin)", RegexOption.IGNORE_CASE)
        ),
        Rule(
            "r_upi_pin_receive", "upi_collect_trap", 55,
            Regex("enter\\s*upi\\s*pin.{0,40}(receive|get|credit)", RegexOption.IGNORE_CASE)
        ),
        Rule(
            "r_fake_challan_02", "fake_challan", 45,
            Regex("(challan|chalan|चालान|चलान).{0,80}(https?://)(?!(echallan\\.gov\\.in|parivahan\\.gov\\.in))", RegexOption.IGNORE_CASE)
        ),
        Rule(
            "r_lottery_01", "lottery", 45,
            Regex("(lottery|winner|kbc|jeeta|पारितोषिक|इनाम|जीत).{0,80}(fee|registration|claim|charge|शुल्क|फ़ीस)", RegexOption.IGNORE_CASE)
        ),
        Rule(
            "r_lottery_02", "lottery", 40,
            Regex("kbc|kaun\\s*banega\\s*crorepati", RegexOption.IGNORE_CASE)
        ),
        Rule(
            "r_fake_electricity_bill", "electricity_bill", 60,
            Regex("electricity\\s*(bill|connection|power).{0,60}(disconnect|cut|off|pending|overdue|night)|बिजली.{0,40}(कट|बंद|काट)|वीज.{0,40}(खंडित|बिल|पुरवठा|बंद)|power.{0,20}disconnect", RegexOption.IGNORE_CASE)
        ),
        Rule(
            "r_phishing_link_02", "phishing_link", 35,
            Regex("https?://[^\\s]*\\.(xyz|top|click|link|work|live|cyou|buzz|quest|gq|tk|ml|cf|ga|site|online|cc|vip)(/|\\?|$|\\s)|bit\\.ly|tinyurl|\\.apk|wa\\.me", RegexOption.IGNORE_CASE)
        ),
        Rule(
            "r_qr_impersonation_01", "qr_impersonation", 55,
            Regex("scan\\s*to\\s*(receive|collect|get)|scan\\s*and\\s*(receive|collect)", RegexOption.IGNORE_CASE)
        ),
        Rule(
            "r_urgency_01", "digital_arrest", 25,
            Regex("(block|ब्लॉक|बंद|suspend).{0,40}(24\\s*hours|2\\s*hours|today\\s*only|आजच|तुरंत|आत्ता|tonight|आज\\s*रात्री)", RegexOption.IGNORE_CASE)
        )
    )

    fun evaluate(text: String): Result {
        val hits = mutableListOf<Hit>()
        for (rule in rules) {
            val match = rule.pattern.find(text)
            if (match != null) {
                val snippet = safeSnippet(match.value)
                hits.add(Hit(rule.id, rule.family, rule.weight, snippet))
            }
        }

        // Family cap: max 70 per family
        val familyScores = hits.groupBy { it.family }
            .mapValues { (_, familyHits) -> minOf(familyHits.sumOf { it.weight }, 70) }

        val totalScore = familyScores.values.sum().coerceIn(0, 100)
        val topFamily = familyScores.maxByOrNull { it.value }?.key ?: "other"

        return Result(totalScore, hits, topFamily)
    }

    private fun safeSnippet(text: String): String {
        val trimmed = text.trim().replace(Regex("\\s+"), " ")
        return if (trimmed.length > 60) trimmed.substring(0, 60) else trimmed
    }

    private data class Rule(
        val id: String,
        val family: String,
        val weight: Int,
        val pattern: Regex
    )
}
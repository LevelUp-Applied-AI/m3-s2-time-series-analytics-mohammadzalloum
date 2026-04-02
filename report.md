# Executive Report — Time-Series Analytics with Window Functions

## Method Notes

- All revenue and order-volume metrics are based on **completed** orders only. Cancelled and returned orders were excluded from revenue.
- Cohorts are defined by **first completed purchase month**, not signup month.
- Retention rates use an **eligibility-adjusted denominator** so that recent cohorts are not unfairly inflated by having less time to generate repeat purchases. For example, 90-day retention comparisons are only fully comparable through the **December 2025** cohort.

## Revenue Trends

The business generated **$9.30M** in completed-order revenue across **27,711 completed orders** during the 12-month window. Revenue scaled rapidly through the back half of the year, rising from **$217.8K in April 2025** to **$1.71M in December 2025**, a **684.3% increase**. Quarterly growth accelerated from **$872.0K in Q2 2025** to **$1.53M in Q3 2025** (**+75.6% QoQ**) and then to **$3.69M in Q4 2025** (**+141.3% QoQ**).

The strongest growth driver was **order volume and customer expansion**, not ticket size. From Q3 to Q4, order count grew from **4,652** to **11,275** (**+142.4%**), while unique customers grew **+80.7%**. Average order value was essentially flat in that same step-up, moving from about **$329** to **$328**. That tells us the Q4 surge was primarily a scale story: more customers and more transactions rather than richer baskets.

There is one clear anomaly in **October 2025**. Revenue rose from **$593.1K in September** to **$791.5K in October** (**+33.5% MoM**) and orders jumped **+59.6%**, but average order value fell **16.4% MoM**. The pricing analysis explains why: average realized discounting moved from **0%** in September to roughly **15%** in October, then snapped back to **0%** in November. In other words, October looks like a promotional month that successfully acquired volume, but at the cost of basket economics.

November and December then compounded that gain. Revenue increased from **$791.5K in October** to **$1.19M in November** (**+50.9%**) and then to **$1.71M in December** (**+43.0%**). December was the peak month on both revenue and orders, and the moving averages confirm this was not just a few holiday spikes. The end-of-month **30-day moving average of daily revenue** climbed to about **$55.2K by December 31**, versus **$25.5K at the end of October**.

After the holiday peak, the business normalized in **January 2026**: revenue fell to **$729.3K** (**-57.3% vs December**) and orders fell to **2,156** (**-56.5%**). That decline looks seasonal rather than structural, because the trend recovered quickly. Revenue rebounded to **$944.4K in February** and **$1.53M in March**, meaning March revenue was **109.9% higher than January**. The 30-day moving average recovered to **$49.8K by March 31**, close to the December peak level.

A second structural insight is the growing importance of repeat demand. Returning customers represented only **38.4% of revenue in Q2**, but that share rose to **67.6% in Q3**, **76.3% in Q4**, and **80.0% in Q1 2026**. That means the business is becoming increasingly retention-driven over time.

## Customer Retention

Cohorts were built using each customer’s **first completed purchase month**, which is the correct behavioral definition for retention analysis. Cohort sizes ranged from **342 customers in May 2025** to **618 in December 2025**.

The weakest early retention came from the summer cohorts. The **July 2025** cohort had the lowest 30-day repeat rate among the mature pre-2026 cohorts at **35.0%**, and its 60-day retention was only **54.7%**. **August 2025** improved slightly at **38.2%** 30-day retention, but still lagged the fall and winter cohorts.

Retention improved materially in the fall. The **October 2025** cohort posted **50.7%** repeat purchase within 30 days, **76.2%** within 60 days, and **89.7%** within 90 days. The **November 2025** cohort improved again to **59.6% / 82.2% / 89.7%**. The standout fully mature cohort is **December 2025**, with **61.8%** 30-day retention, **80.7%** 60-day retention, and **93.0%** 90-day retention.

Recent cohorts look even stronger on short-horizon retention, but they must be interpreted carefully because only part of those cohorts has full follow-up. Even with that caveat, the **February 2026** cohort is notable because the full cohort is mature for 30-day analysis and achieved **87.9%** repeat purchase within 30 days. The **January 2026** cohort also posted a very strong **93.6% 60-day retention** among the customers with a full 60-day observation window.

The broad pattern is clear: customers acquired in the second half of the year retained much better than customers acquired in early summer. That suggests either a shift in acquisition quality, a more effective merchandising calendar, or both. The October promotion appears to have increased acquisition volume, while the strong November–December retention suggests that many of those newer customers were high quality rather than purely one-time bargain hunters.

## Category Performance

The business is becoming more concentrated in **Electronics**. Electronics generated **$446.1K in Q2 2025**, **$809.0K in Q3**, **$2.07M in Q4**, and **$1.86M in Q1 2026**. Its revenue share rose from **51.2% in Q2** to **52.9% in Q3**, **56.1% in Q4**, and **58.2% in Q1 2026**. Electronics alone contributed **58.4%** of the total Q4-over-Q3 revenue increase, making it the primary growth engine.

Other categories grew in absolute dollars but lost share over time. **Sports** rose from **$138.4K in Q2** to **$525.3K in Q4**, then eased to **$446.0K in Q1**; however, its share slid from **15.9% in Q2** to **13.9% in Q1**. **Home & Kitchen** followed a similar path, moving from **14.8% share** in Q2 to **13.1%** in Q1 despite strong absolute revenue growth. **Clothing** declined more clearly in mix, dropping from **12.1% share in Q2** to **9.9% in Q1**. **Books** and **Health & Beauty** remained small and became slightly smaller as a percentage of sales.

This mix shift matters because the company’s growth is not broad-based. Revenue is increasing, but more of it is coming from a single category. That is efficient while Electronics is working, but it creates concentration risk if demand softens, margins compress, or inventory constraints appear in that category.

## Recommendations

### 1. Repeat the October demand-generation playbook, but only with margin controls.
October’s **+59.6%** jump in orders shows that promotion can unlock demand quickly, but the accompanying **15% discount rate** and **16.4% drop in AOV** show the economic cost. The next-quarter version should use tighter guardrails: target promotions to first-order acquisition or slow-moving SKUs, cap discount depth, and measure 60-day payback rather than just top-line lift.

### 2. Shift more budget toward the channels, campaigns, and merchandising windows that produced the November–February cohorts.
The best mature retention results cluster in late 2025 and early 2026. December delivered **93.0% 90-day retention**, and February delivered **87.9% 30-day retention**. Acquisition sources that fed those cohorts deserve more budget because they appear to be bringing in customers who continue purchasing.

### 3. Build explicit win-back programs for the July–August style cohorts.
The weakest cohorts were acquired in mid-summer, where 30-day retention fell to **35.0%–38.2%**. Those customers need a different second-purchase strategy: post-purchase email/SMS sequences, category-specific replenishment prompts, and personalized offers within the first 14–21 days after the first order.

### 4. Lean into Electronics, but reduce concentration risk through cross-sell.
Electronics is the growth engine, contributing **58.4% of the Q4 growth jump** and rising to **58.2% of Q1 revenue**. That warrants continued investment in inventory, placement, and marketing. However, every Electronics order should be treated as an entry point to attach **Home & Kitchen**, **Sports**, or **Clothing** items through bundles, recommendations, and cart-level offers so growth becomes more diversified.

### 5. Forecast next quarter with a seasonality-adjusted base, not December’s holiday peak.
January’s sharp reset and March’s rebound show the business has both seasonality and momentum. Planning should anchor on the recovering trend line—roughly the **$49.8K 30-day daily revenue run rate at the end of March**—instead of using December’s holiday spike as the baseline.

## Bottom Line

The company is in a strong growth phase, and the most encouraging signal is not just higher revenue—it is that **repeat-customer revenue is becoming the dominant driver**. The next quarter should focus on preserving that retention momentum, using promotions more selectively, and turning Electronics-led demand into broader multi-category growth.

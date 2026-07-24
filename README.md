# Late Delivery & Revenue-at-Risk Analysis (Olist)

**Question:** What's actually causing late deliveries on Olist, and how much repeat-purchase revenue do they cost?

> Built to answer a real business question end-to-end — SQL → analysis → dashboard → recommendation — on the Olist Brazilian E-Commerce dataset (~96,000 delivered orders, Sep 2016–Aug 2018).

![Dashboard](assets/dashboard.png)
<!-- Export a full-resolution PNG of your Tableau dashboard and save it as assets/dashboard.png -->

## Key numbers

| Metric | Finding |
|---|---|
| **Overall late rate** | 8.1% of delivered orders |
| **Routing effect** | Cross-state shipments 50% more likely to be late (9.3% vs 6.1%) |
| **Satisfaction cost** | Late orders average **2.6 stars** vs **4.3** on-time; 54% leave a 1–2 star review vs 9% |
| **Repeat-purchase gap** | 2.5% vs 3.0% (statistically significant, p = 0.011) |
| **Repeat revenue at risk** | ~\$6,400 (lower-bound estimate; excludes reputational spillover) |

## The memo

Late deliveries — 8.1% of Olist's ~96,000 delivered orders — are a geography problem, not a product or seller-quality one: shipments that cross a state line are 50% more likely to arrive late (9.3% vs. 6.1%), remote states like Maranhão and Ceará run 2–3x the national late rate, and late rates are flat across every major product category. The satisfaction cost is severe and immediate — late orders average a 2.57-star review versus 4.29 for on-time orders, with 54% of late-order customers leaving a 1- or 2-star review versus 9% of on-time customers. That satisfaction gap does translate into lost repeat business: customers whose first order arrives late come back at a 2.52% rate versus 3.04% for on-time customers (statistically significant, p = 0.011), worth an estimated **\$6,400** in forgone repeat revenue over this two-year window. That figure almost certainly understates the true cost, since it can't capture word-of-mouth or public 1-star reviews deterring *other* prospective customers who never show up in this data at all. **Recommendation:** rather than investing broadly in delivery-time improvements, target fulfillment and carrier capacity at the small set of high-late-rate states (Maranhão, Ceará, Bahia, Pará, Espírito Santo) where the problem is concentrated — this is a routing/logistics fix, not a seller-quality one, and the geographic concentration means a handful of regional carrier partnerships could meaningfully move the needle.

## Dashboard

**[View the interactive dashboard on Tableau Public](PASTE_YOUR_TABLEAU_PUBLIC_LINK_HERE)**
<!-- Publish to Tableau Public, then paste the public URL above. -->

## Repo structure

```
sql/                    Standalone, commented SQL — one file per analysis step
notebook/analysis.ipynb Runs the full pipeline end-to-end, produces data_exports/
data_exports/           Clean, aggregated CSVs + summary_metrics.json (feeds the dashboard)
assets/                 Dashboard image(s) used in this README
data/                   Raw Olist CSVs (not committed — see Reproducing below)
```

| File | What it answers |
|---|---|
| `sql/01_late_delivery_rate.sql` | What share of orders are late, at baseline? |
| `sql/02_causes_geography.sql` | Does customer location / shipping route predict lateness? |
| `sql/03_causes_category.sql` | Control check: does product category predict lateness? (It doesn't.) |
| `sql/04_review_score_impact.sql` | How much does a late delivery move the review score? |
| `sql/05_repeat_purchase_cohort.sql` | Does a late first order change whether a customer comes back? |
| `sql/06_revenue_at_risk.sql` | Converts the repeat-rate gap into a dollar estimate |

## Methodology notes (the parts a reviewer will check first)

- **`customer_unique_id`, not `customer_id`.** Olist assigns a new `customer_id` to every order; only `customer_unique_id` identifies the same person across orders. Joining on `customer_id` would make every customer look like a one-time buyer by construction — the most common mistake in public Olist analyses. Baseline repeat-purchase rate here is ~3%, matching other published analyses of this dataset.
- **"Late" is defined as** \`order_delivered_customer_date > order_estimated_delivery_date\`, scoped to \`order_status = 'delivered'\` only.
- **Route (same-state vs. different-state)** uses each order's first item (\`order_item_id = 1\`) as the representative seller, since ~1.3% of orders span multiple sellers and would otherwise be ambiguous.
- **The revenue-at-risk figure is a lower bound**, by design — it only counts the direct effect on the same customer's future spend, not reputational spillover to other customers.

## Reproducing

1. Download the [Olist Brazilian E-Commerce dataset](https://www.kaggle.com/olistbr/brazilian-ecommerce) (or the mirror at [olist/work-at-olist-data](https://github.com/olist/work-at-olist-data)) and place the 9 CSVs in \`data/\`.
2. \`pip install -r requirements.txt\`
3. Run \`notebook/analysis.ipynb\` top to bottom. It loads the CSVs into DuckDB, runs each analysis step, and writes \`data_exports/\`.

## Stack

DuckDB (SQL analysis) · Python/Pandas (pipeline + stats) · Tableau Public (dashboard)

---

*Built by Raashid Shaik — [LinkedIn](https://www.linkedin.com/in/raashidshaik45) · [Portfolio](https://raashidshaik.github.io)*

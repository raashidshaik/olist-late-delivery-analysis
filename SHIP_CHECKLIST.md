# Ship Checklist — do these, then send Colin

Everything in this folder is ready. These are the only manual steps left.

## 1. Publish the dashboard to Tableau Public (~10 min)
- In Tableau Desktop: Server > Tableau Public > Save to Tableau Public As...
  (free account at public.tableau.com if you don't have one)
- Once live, copy the public URL.
- Open README.md and replace  PASTE_YOUR_TABLEAU_PUBLIC_LINK_HERE  with that URL.

## 2. Add the dashboard image (~2 min)
- In Tableau: Dashboard > Export > Image... > save as PNG.
- Name it exactly  dashboard.png  and put it in the  assets/  folder here.
- (Delete assets/README.txt afterward — it's just a placeholder note.)

## 3. Push to GitHub (~10 min)
- Create a new PUBLIC repo, e.g.  olist-late-delivery-analysis
- Drag every file/folder from THIS folder into it (or: git init, add, commit, push).
- Do NOT commit the raw Olist CSVs — the .gitignore already excludes the data/ folder.
- Confirm the README renders: dashboard image shows, Tableau link works.

## 4. Send Colin (Friday morning)
- Reply IN THE SAME LinkedIn thread (don't start a new message).
- Message text is in  colin_message.txt  — paste the GitHub link into it.

## 5. Reuse it
- After Colin, this same repo link becomes the hook for Sigma, Hex, Amplitude,
  and every interview: "I built a self-serve analytics project — happy to share."
- Add the repo link to your portfolio site (raashidshaik.github.io).

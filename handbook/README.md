# The Handbook — editions

The chapter-close package suggested this directory for the Handbook's
editions. To keep single copies of the binaries (the site must serve them
anyway), they live under `site/static/` instead:

| Edition | File | Served at |
| ------- | ---- | --------- |
| **v3 print (current, interim pre-designer)** | `site/static/handbook/Council_Handbook_v3_PRINT_bw.pdf` | `/handbook/Council_Handbook_v3_PRINT_bw.pdf` |
| Review Edition (annotated, rich diff + proposals) | `site/static/archive/pdf/25_Council_Handbook_Review.pdf` | `/archive/pdf/25_Council_Handbook_Review.pdf` |
| Rich diff (browsable) | `site/static/archive/docs/25_Council_Handbook_RichDiff.html` | `/archive/docs/25_Council_Handbook_RichDiff.html` |

When the designer's pass comes back, replace
`site/static/handbook/Council_Handbook_v3_PRINT_bw.pdf` (or add the new file
beside it and update the link in `site/content/rules/_index.md` and the
`url` entry in `site/data/archive.toml`).

The change record for v3 is [`/CHANGELOG_v3.md`](../CHANGELOG_v3.md); the
review that produced it is archived in [`/reviews/`](../reviews/).

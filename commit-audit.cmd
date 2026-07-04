@echo off
REM Final step: verify pages on the dev server, re-run audit, then commit.
cd /d "%~dp0"

echo [1/4] Verifying pages on http://localhost:3000 ...
(
  for %%u in (/quarries /privacy /terms /cookies /materials/fantasy-brown /materials/brasilia-red /materials/thassos-white /datasheet/thassos-white /catalogue /no-such-page) do (
    curl -s -o NUL -w "%%u -> %%{http_code}\n" "http://localhost:3000%%u"
  )
) > verify-report.txt 2>&1

echo [2/4] Re-running data audit...
call npx tsx prisma/audit-stones.ts > audit-report.txt 2>&1

echo [3/4] Typecheck...
call npx tsc --noEmit > tsc-report.txt 2>&1

echo [4/4] Committing...
git add -A
git -c user.name="DIJA" -c user.email="dijastones@gmail.com" commit -m "Expert content audit + dev hardening pass" -m "Stone-industry corrections: ~51 slip labels honed-to-polished (wet <=15 is a polished figure); Languedoc Jaune/Rouge specs corrected from soft-limestone to compact-marble values, ages to Devonian (Montagne Noire); Griotte Rouge age to Devonian; Balmoral Red renamed Brasilia Red (record described the Brazilian red, not the Finnish rapakivi); Fantasy Brown retyped Quartzite to Marble with dolomite flag and disclosure (industry-notorious misnomer); restored dm dolomitic field dropped in Phase-1 migration (6 Greek whites) with badges on material page, catalogue and datasheet; added Iran quarry profile EN+FR (10 Iranian stones had no sourcing entry) plus Zagros Belt region; stats made data-driven (home, quarries, catalogue: stone/country/office counts, office city list, HQ address from DB); fixed 3-continents-to-4, 170+-pages-to-160+, Istanbul missing from office list." -m "Dev hardening: legal pages /privacy /terms /cookies (footer linked 404s), branded 404 + error pages, security headers, metadataBase, robots disallows /datasheet + /compare, legacy /materials/[id]/datasheet now redirects, audit validator (prisma/audit-stones.ts) tuned against reviewed catalogue, first production build green (50 routes)." -m "Co-Authored-By: Claude Fable 5 <noreply@anthropic.com>" > commit-report.txt 2>&1

echo Done. Tell Claude "done".

@echo off
REM Verify the mobile-menu fix, account overhaul, and admin delete; then commit.
cd /d "%~dp0"

echo [1/4] Typecheck...
call npx tsc --noEmit > tsc-report.txt 2>&1

echo [2/4] Production build...
call npm run build > build-report.txt 2>&1

echo [3/4] Verifying routes on http://localhost:3000 ...
(
  for %%u in (/ /materials /materials/thassos-white /account /account/proformas /login /catalogue /quarries) do (
    curl -s -o NUL -w "%%u -> %%{http_code}\n" "http://localhost:3000%%u"
  )
  echo --- admin delete must be guarded when logged out:
  curl -s -o NUL -w "DELETE /api/admin/stones/x unauth -> %%{http_code}\n" -X DELETE "http://localhost:3000/api/admin/stones/x"
) > verify-report.txt 2>&1

echo [4/4] Committing...
git add -A
git -c user.name="DIJA" -c user.email="dijastones@gmail.com" commit -m "Fix mobile menu; overhaul My Account; admin stone delete; grid dolomite badges" -m "Mobile menu: submenus (Stone/Atelier/Trade) never opened on phones - the stylesheet expands them via the .open class on .mobile-nav-parent (max-height transition), but the header set inline display on the subnav instead; the class is now applied to the parent as the CSS expects." -m "My Account: account sub-nav (Dashboard / My Proformas / New proforma / Sign out) on all account pages; dashboard now shows a recent-proformas card with totals, status and view-all; favorites get an explicit Remove button (new idempotent remove action in /api/favorites) and server favorites now sync to localStorage on dashboard load so hearts match the account across devices; proformas list gets colored status badges." -m "Admin: stones can be deleted (list + editor, confirm dialog) via new DELETE /api/admin/stones/[id], which also cleans up client favorites referencing the stone." -m "Also: Dolomite badge now shows on grid cards (dm added to card selects), and the earlier defensive dm casts were replaced with direct field reads now the client is regenerated." -m "Co-Authored-By: Claude Fable 5 <noreply@anthropic.com>" > commit-report.txt 2>&1

echo Done. Tell Claude "done".

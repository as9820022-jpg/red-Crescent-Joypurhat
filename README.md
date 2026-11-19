# Bangladesh Red Crescent Society – Joypurhat Unit Portal

Bilingual (Bangla/English) React + Vite starter for a volunteer and public knowledge portal.

## Included
- Responsive public website with Bangla/English language switch
- Home, About, Activities, Notice Board, Knowledge Hub and Contact pages
- Volunteer registration/login UI (Supabase Auth when configured)
- Volunteer dashboard shell
- Supabase database schema and starter RLS policies
- Knowledge Hub topic directory (movement history, Bangladesh Red Crescent, seven principles, first aid, disaster management, youth)

## Run locally
1. Install Node.js 20+.
2. Copy `.env.example` to `.env`.
3. `npm install`
4. `npm run dev`

The site runs in preview mode without Supabase. Authentication and database writes require a Supabase project.

## Connect Supabase
1. Create a Supabase project.
2. Run `supabase/schema.sql` in the Supabase SQL Editor.
3. Copy the Project URL and anon/public key into `.env`:
   - `VITE_SUPABASE_URL`
   - `VITE_SUPABASE_ANON_KEY`
4. Configure Supabase Auth email confirmation and your production redirect URLs.
5. Test registration, email verification, login, profile creation and contact submission.

## Deploy
- Build: `npm run build`
- Deploy the `dist/` folder to Vercel, Netlify or another static hosting provider.
- Add the two VITE_ environment variables in the hosting dashboard.
- Configure SPA fallback/rewrite to `/index.html`.
- Add your production domain to Supabase Auth redirect URL allow-list and enable HTTPS.

## Important production checklist
This is a deployable starter, not yet an officially approved/live unit website. Before public launch:
- Obtain written unit/branch approval for official name, emblem, brand assets and content.
- Replace placeholder email/phone and add verified address/social links.
- Have the unit review all historical, policy, first-aid and emergency content before publication.
- Configure admin-only server-side functions and RLS policies before enabling admin CRUD. Never assign admin from client-side form metadata.
- Add spam protection/rate limiting to contact form, backups, privacy notice, terms, accessibility checks and security review.
- Do not collect national ID, medical details or other sensitive data unless the unit has a lawful, approved process and retention policy.
- Do not put Supabase service_role keys in frontend environment variables.
- Use only authorized Red Crescent emblem/logo assets. The current hero art and icon are placeholders, not official branding.

## Suggested admin setup
Create the first administrator only after confirming their identity and authorization. In Supabase SQL Editor, update the verified profile UUID to `role='admin'` and `status='approved'`. Then implement admin CRUD through protected server-side endpoints/Edge Functions with explicit role checks and audit logs. The current starter intentionally does not expose public admin privileges.

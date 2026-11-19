-- Run this SQL in the Supabase SQL Editor.
-- IMPORTANT: Never expose the service_role key in the browser.
create extension if not exists pgcrypto;

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  full_name text not null default '',
  phone text,
  status text not null default 'pending' check (status in ('pending','approved','rejected','suspended')),
  role text not null default 'volunteer' check (role in ('volunteer','admin')),
  created_at timestamptz not null default now()
);

create table if not exists public.notices (
  id uuid primary key default gen_random_uuid(),
  title_bn text not null,
  title_en text not null,
  body_bn text not null default '',
  body_en text not null default '',
  published boolean not null default false,
  created_at timestamptz not null default now()
);

create table if not exists public.activities (
  id uuid primary key default gen_random_uuid(),
  title_bn text not null,
  title_en text not null,
  description_bn text not null default '',
  description_en text not null default '',
  event_date date,
  image_url text,
  published boolean not null default false,
  created_at timestamptz not null default now()
);

create table if not exists public.knowledge_articles (
  id uuid primary key default gen_random_uuid(),
  slug text unique not null,
  title_bn text not null,
  title_en text not null,
  body_bn text not null default '',
  body_en text not null default '',
  category text not null default 'general',
  published boolean not null default false,
  created_at timestamptz not null default now()
);

create table if not exists public.contact_messages (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  email text not null,
  phone text,
  message text not null,
  created_at timestamptz not null default now()
);

alter table public.profiles enable row level security;
alter table public.notices enable row level security;
alter table public.activities enable row level security;
alter table public.knowledge_articles enable row level security;
alter table public.contact_messages enable row level security;

-- Profile owners can read/update only their own basic profile.
create policy "profile read own" on public.profiles for select to authenticated using (auth.uid() = id);
create policy "profile update own" on public.profiles for update to authenticated using (auth.uid() = id) with check (auth.uid() = id and role = 'volunteer');

-- Public can read published content only.
create policy "published notices readable" on public.notices for select to anon, authenticated using (published = true);
create policy "published activities readable" on public.activities for select to anon, authenticated using (published = true);
create policy "published knowledge readable" on public.knowledge_articles for select to anon, authenticated using (published = true);

-- Contact form accepts inserts. Keep messages private from public reads.
create policy "contact form insert" on public.contact_messages for insert to anon, authenticated with check (true);

-- Create a profile automatically when a user signs up.
create or replace function public.handle_new_user()
returns trigger language plpgsql security definer set search_path = public as $$
begin
  insert into public.profiles (id, full_name, phone)
  values (new.id, coalesce(new.raw_user_meta_data->>'full_name',''), new.raw_user_meta_data->>'phone');
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created after insert on auth.users
for each row execute procedure public.handle_new_user();

-- Admin role must be assigned manually by a trusted project owner in the SQL editor.
-- Example after verifying the person's auth UUID:
-- update public.profiles set role='admin', status='approved' where id='AUTH-USER-UUID';
-- Add admin-only RLS policies after reviewing the final admin workflow.

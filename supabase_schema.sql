-- ====================================================================
-- SkillForgeAI: Supabase SQL Database Schema
-- Paste this script into your Supabase SQL Editor to set up the DB tables
-- ====================================================================

-- 1. Create Profiles Table (extends Supabase Auth Users)
CREATE TABLE IF NOT EXISTS public.profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    email TEXT,
    phone TEXT,
    name TEXT,
    age INT,
    level TEXT, -- e.g., 'Under grad', 'Post grad'
    branch TEXT, -- e.g., 'CSE', 'AIML', 'ECE'
    subjects TEXT[], -- Array of core course subjects
    city TEXT,
    college TEXT,
    interests TEXT[], -- Selected skills or domains
    timeline TEXT, -- learning consistency commitment (e.g., '2 months', '6 months')
    gpa TEXT DEFAULT '3.6 / 4.0', -- GPA or academic score
    career_sector TEXT DEFAULT 'Big Tech & SaaS', -- Target recruiter vertical
    skill_focus TEXT DEFAULT 'Software Engineering', -- Core student skill direction
    avatar_url TEXT DEFAULT '', -- Base64 data URL or external asset url
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- Enable Row Level Security for profiles
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

-- Profiles Policies
CREATE POLICY "Allow public read-access for profiles" 
    ON public.profiles FOR SELECT USING (true);

CREATE POLICY "Allow users to update their own profiles" 
    ON public.profiles FOR UPDATE USING (auth.uid() = id);

CREATE POLICY "Allow users to insert their own profiles" 
    ON public.profiles FOR INSERT WITH CHECK (auth.uid() = id);


-- 2. Create Scores & Learning Progress Table
CREATE TABLE IF NOT EXISTS public.scores (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    test_type TEXT NOT NULL, -- 'tech_training', 'aptitude', 'mock_interview'
    score INT NOT NULL, -- Score from 0 to 100
    details JSONB, -- Stores questions, answers, and improvement recommendations
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- Enable RLS for scores
ALTER TABLE public.scores ENABLE ROW LEVEL SECURITY;

-- Scores Policies
CREATE POLICY "Allow users to view their own scores" 
    ON public.scores FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Allow users to insert their own scores" 
    ON public.scores FOR INSERT WITH CHECK (auth.uid() = user_id);


-- 3. Create Resumes Table
CREATE TABLE IF NOT EXISTS public.resumes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE UNIQUE NOT NULL,
    summary TEXT,
    skills TEXT[],
    experience JSONB DEFAULT '[]'::jsonb, -- Array of jobs
    education JSONB DEFAULT '[]'::jsonb, -- Array of colleges
    projects JSONB DEFAULT '[]'::jsonb, -- Array of projects
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- Enable RLS for resumes
ALTER TABLE public.resumes ENABLE ROW LEVEL SECURITY;

-- Resumes Policies
CREATE POLICY "Allow public read-access for resumes (portfolio)" 
    ON public.resumes FOR SELECT USING (true);

CREATE POLICY "Allow users to update/insert their own resume" 
    ON public.resumes FOR ALL USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);


-- ====================================================================
-- Automated Setup Triggers (Optional Helper)
-- ====================================================================

-- Function to handle new signups and create a shell profile record
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger AS $$
BEGIN
  INSERT INTO public.profiles (id, email, name, gpa, career_sector, skill_focus, avatar_url)
  VALUES (
    new.id, 
    new.email, 
    COALESCE(new.raw_user_meta_data->>'name', 'New Student'),
    COALESCE(new.raw_user_meta_data->>'gpa', '3.6 / 4.0'),
    COALESCE(new.raw_user_meta_data->>'career_sector', 'Big Tech & SaaS'),
    COALESCE(new.raw_user_meta_data->>'skill_focus', 'Software Engineering'),
    COALESCE(new.raw_user_meta_data->>'avatar_url', '')
  );
  
  INSERT INTO public.resumes (user_id, summary, skills, experience, education, projects)
  VALUES (new.id, '', '{}', '[]'::jsonb, '[]'::jsonb, '[]'::jsonb);
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger to execute function on auth.users insert
CREATE OR REPLACE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

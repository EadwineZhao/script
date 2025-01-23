-- v14.1
DO $$
BEGIN
    IF NOT EXISTS (SELECT * FROM information_schema.columns 
                   WHERE column_name = 'Rank' AND table_name = 'FriendLink') THEN
        ALTER TABLE FriendLink ADD COLUMN "Rank" INT;
        UPDATE FriendLink SET "Rank" = 0;
        ALTER TABLE FriendLink ALTER COLUMN "Rank" SET NOT NULL;
    END IF;
END $$;

-- v14.3
DO $$
BEGIN
    IF NOT EXISTS (SELECT * FROM information_schema.tables 
                   WHERE table_name = 'LoginHistory') THEN
        CREATE TABLE "LoginHistory" (
            "Id" SERIAL PRIMARY KEY,
            "LoginTimeUtc" TIMESTAMP NOT NULL,
            "erAgent" TEXT,
            "fingerprint" TEXT
        );
    END IF;
END $$;

DO $$
BEGIN
    IF EXISTS (SELECT * FROM information_schema.tables 
               WHERE table_name = 'LocalAccount') THEN
        DROP TABLE "LocalAccount";
    END IF;
END $$;

DO $$
BEGIN
    IF EXISTS (SELECT * FROM information_schema.columns 
               WHERE column_name = 'RouteName' AND table_name = 'Catery') THEN
        ALTER TABLE Catery RENAME COLUMN "RouteName" TO "Slug";
    END IF;
END $$;

DO $$
BEGIN
    IF EXISTS (SELECT 1 
               FROM information_schema.columns c
               JOIN information_schema.tables t ON c.table_name = t.table_name
               WHERE t.table_name = 'Post' AND c.column_name = 'InlineCss') THEN
        ALTER TABLE Post DROP COLUMN "InlineCss";
    END IF;
END $$;

-- v14.5
DO $$
BEGIN
    IF EXISTS (SELECT * FROM information_schema.columns 
               WHERE column_name = 'IsOriginal' AND table_name = 'Post') THEN
        ALTER TABLE Post DROP COLUMN "IsOriginal";
    END IF;
END $$;

DO $$
BEGIN
    IF EXISTS (SELECT * FROM information_schema.columns 
               WHERE column_name = 'OriginLink' AND table_name = 'Post') THEN
        ALTER TABLE Post DROP COLUMN "OriginLink";
    END IF;
END $$;

DO $$
BEGIN
    IF NOT EXISTS (SELECT * FROM information_schema.tables 
                   WHERE table_name = 'Mention') AND 
       EXISTS (SELECT * FROM information_schema.tables 
               WHERE table_name = 'Pingback') THEN
        ALTER TABLE Pingback RENAME TO Mention;
    END IF;
END $$;

DO $$
BEGIN
    IF NOT EXISTS (SELECT * FROM information_schema.columns 
                   WHERE column_name = 'Worker' AND table_name = 'Mention') THEN
        ALTER TABLE Mention ADD COLUMN "Worker" VARCHAR(16);
        UPDATE Mention SET "Worker" = 'Pingback';
    END IF;
END $$;

-- v14.8
DO $$
BEGIN
    IF NOT EXISTS (SELECT * FROM information_schema.columns 
                   WHERE column_name = 'RouteLink' AND table_name = 'Post') THEN
        ALTER TABLE Post ADD COLUMN "RouteLink" VARCHAR(256);
        UPDATE Post SET "RouteLink" = TO_CHAR("PubDateUtc", 'YYYY/M/D') || '/' || "Slug";
    END IF;
END $$;

DO $$
BEGIN
    IF EXISTS (SELECT 1 
               FROM information_schema.columns c
               JOIN information_schema.tables t ON c.table_name = t.table_name
               WHERE t.table_name = 'Post' AND c.column_name = 'HashCheckSum') THEN
        ALTER TABLE Post DROP COLUMN "HashCheckSum";
    END IF;
END $$;

-- v14.15
DO $$
BEGIN
    UPDATE "BlogConfiguration" SET "CfgKey" = 'AppearanceSettings' WHERE "CfgKey" = 'CustomStyleSheetSettings';
    ALTER TABLE "BlogConfiguration" ALTER COLUMN "CfgKey" SET NOT NULL;
    IF EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'PK_BlogConfiguration') THEN
        ALTER TABLE "BlogConfiguration" DROP CONSTRAINT "PK_BlogConfiguration";
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_constraint 
                   WHERE conname = 'PK_BlogConfiguration_CfgKey' 
                   AND conrelid = 'BlogConfiguration'::regclass) THEN
        ALTER TABLE "BlogConfiguration" ADD CONSTRAINT "PK_BlogConfiguration_CfgKey" PRIMARY KEY ("CfgKey");
    END IF;
    IF EXISTS (SELECT 1 FROM information_schema.columns 
               WHERE table_name = 'BlogConfiguration' AND column_name = 'Id') THEN
        ALTER TABLE "BlogConfiguration" DROP COLUMN "Id";
    END IF;
END $$;

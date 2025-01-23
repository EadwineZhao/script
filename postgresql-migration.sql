DO $$
BEGIN
    IF NOT EXISTS (SELECT * FROM information_schema.columns 
                   WHERE table_name = 'FriendLink' AND column_name = 'Rank') THEN
        EXECUTE 'ALTER TABLE FriendLink ADD Rank INT';
        EXECUTE 'UPDATE FriendLink SET Rank = 0';
        EXECUTE 'ALTER TABLE FriendLink ALTER COLUMN Rank SET NOT NULL';
    END IF;
END $$;

DO $$
BEGIN
    IF NOT EXISTS (SELECT * FROM information_schema.tables 
                   WHERE table_name = 'LoginHistory') THEN
        CREATE TABLE LoginHistory (
            Id SERIAL PRIMARY KEY,
            LoginTimeUtc TIMESTAMP NOT NULL,
            UserAgent VARCHAR(255)
        );
    END IF;
END $$;

DO $$
BEGIN
    IF EXISTS (SELECT * FROM information_schema.tables 
               WHERE table_name = 'LocalAccount') THEN
        DROP TABLE LocalAccount;
    END IF;
END $$;

DO $$
BEGIN
    IF EXISTS (SELECT * FROM information_schema.columns 
               WHERE table_name = 'Catery' AND column_name = 'RouteName') THEN
        EXECUTE 'ALTER TABLE Catery RENAME COLUMN RouteName TO Slug';
    END IF;
END $$;

DO $$
BEGIN
    IF EXISTS (SELECT * FROM information_schema.columns 
               WHERE table_name = 'Post' AND column_name = 'InlineCss') THEN
        ALTER TABLE Post DROP COLUMN InlineCss;
    END IF;
END $$;

DO $$
BEGIN
    IF EXISTS (SELECT * FROM information_schema.columns 
               WHERE table_name = 'Post' AND column_name = 'IsOriginal') THEN
        ALTER TABLE Post DROP COLUMN IsOriginal;
    END IF;
END $$;

DO $$
BEGIN
    IF EXISTS (SELECT * FROM information_schema.columns 
               WHERE table_name = 'Post' AND column_name = 'OriginLink') THEN
        ALTER TABLE Post DROP COLUMN OriginLink;
    END IF;
END $$;

DO $$
BEGIN
    IF NOT EXISTS (SELECT * FROM information_schema.tables 
                   WHERE table_name = 'Mention') AND EXISTS (SELECT * FROM information_schema.tables 
                                                               WHERE table_name = 'Pingback') THEN
        EXECUTE 'ALTER TABLE Pingback RENAME TO Mention';
    END IF;
END $$;

DO $$
BEGIN
    IF NOT EXISTS (SELECT * FROM information_schema.columns 
                   WHERE table_name = 'Mention' AND column_name = 'Worker') THEN
        EXECUTE 'ALTER TABLE Mention ADD Worker VARCHAR(16)';
        EXECUTE 'UPDATE Mention SET Worker = ''Pingback''';
    END IF;
END $$;

DO $$
BEGIN
    IF NOT EXISTS (SELECT * FROM information_schema.columns 
                   WHERE table_name = 'Post' AND column_name = 'RouteLink') THEN
        EXECUTE 'ALTER TABLE Post ADD RouteLink VARCHAR(256)';
        EXECUTE 'UPDATE Post SET RouteLink = TO_CHAR(PubDateUtc, ''YYYY/MM/DD'') || ''/'' || Slug';
    END IF;
END $$;

DO $$
BEGIN
    IF EXISTS (SELECT * FROM information_schema.columns 
               WHERE table_name = 'Post' AND column_name = 'HashCheckSum') THEN
        ALTER TABLE Post DROP COLUMN HashCheckSum;
    END IF;
END $$;

UPDATE BlogConfiguration SET CfgKey = 'AppearanceSettings' WHERE CfgKey = 'CustomStyleSheetSettings';

ALTER TABLE BlogConfiguration ALTER COLUMN CfgKey TYPE VARCHAR(64);

IF EXISTS (SELECT * FROM information_schema.table_constraints 
           WHERE constraint_name = 'PK_BlogConfiguration') THEN
    ALTER TABLE BlogConfiguration DROP CONSTRAINT PK_BlogConfiguration;
END IF;

IF NOT EXISTS (SELECT * FROM information_schema.table_constraints 
               WHERE constraint_name = 'PK_BlogConfiguration_CfgKey') THEN
    ALTER TABLE BlogConfiguration ADD CONSTRAINT PK_BlogConfiguration_CfgKey PRIMARY KEY (CfgKey);
END IF;

IF EXISTS (SELECT * FROM information_schema.columns 
           WHERE table_name = 'BlogConfiguration' AND column_name = 'Id') THEN
    ALTER TABLE BlogConfiguration DROP COLUMN Id;
END IF;

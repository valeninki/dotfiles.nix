{
  pkgs,
  ...
}:

let
  syncLogMigrationPatch = pkgs.writeText "nextcloud-sync-log-migration.patch" ''
    diff --git a/src/gui/application.cpp b/src/gui/application.cpp
    index 277f9344a..0386b7328 100644
    --- a/src/gui/application.cpp
    +++ b/src/gui/application.cpp
    @@ -564,6 +564,24 @@ void Application::setupConfigFile()
             return;
         }

    +    const auto oldDirEntries = QDir(oldDir).entryInfoList(QDir::AllEntries | QDir::NoDotAndDotDot);
    +    bool containsOnlySyncLogs = !oldDirEntries.isEmpty();
    +    for (const auto &entry : oldDirEntries) {
    +        const auto name = entry.fileName();
    +        if (!entry.isFile()
    +            || (!name.endsWith(QLatin1String("_sync.log"))
    +                && !name.endsWith(QLatin1String("_sync.log.1")))) {
    +            containsOnlySyncLogs = false;
    +            break;
    +        }
    +    }
    +
    +    // SyncRunFileLog deliberately stores these in AppDataLocation. They are
    +    // current logs, not configuration left behind by an old client version.
    +    if (containsOnlySyncLogs) {
    +        return;
    +    }
    +
         auto confDir = ConfigFile().configPath();

         // macOS 10.11.x does not like trailing slash for rename/move.
  '';

  nextcloudClient = pkgs.nextcloud-client.overrideAttrs (oldAttrs: {
    patches = (oldAttrs.patches or [ ]) ++ [ syncLogMigrationPatch ];
  });
in
{

  home.packages = [ nextcloudClient ];

  services = {
    nextcloud-client = {
      enable = true;
      package = nextcloudClient;
      startInBackground = true;
    };
  };

}

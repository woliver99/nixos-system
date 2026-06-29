{ pkgs, ... }:

let
  zattooApp = pkgs.writeShellScriptBin "zattoo-app" ''
    PROFILE_DIR="$HOME/.config/zattoo-app-profile"

    # If the app is already open, do nothing when clicked again
    if pgrep -f "firefox.*zattoo-app-profile" > /dev/null; then
      exit 0
    fi

    mkdir -p "$PROFILE_DIR/chrome"

    # 1. Inject configurations directly to user.js
    cat <<EOF > "$PROFILE_DIR/user.js"
    user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);

    // CRITICAL: Allow Firefox to draw its client-side titlebar so GNOME buttons exist
    user_pref("browser.tabs.drawInTitlebar", true); 

    // Clean SOCKS5 Proxy Routing Configuration
    user_pref("network.proxy.type", 1);
    user_pref("network.proxy.socks", "ch.proxy.maplenetwork.ca");
    user_pref("network.proxy.socks_port", 1080);
    user_pref("network.proxy.socks_version", 5);
    user_pref("network.proxy.socks_remote_dns", true);

    // Strict Annoyance Blockers
    user_pref("browser.shell.checkDefaultBrowser", false);
    user_pref("signon.rememberSignons", false);
    user_pref("datareporting.policy.dataSubmissionPolicyBypassNotificationSeen", true);
    user_pref("browser.search.suggest.enabled", false);
    user_pref("privacy.sanitize.sanitizeOnShutdown", false);

    // Force all new windows/links to open in the active tab instead
    user_pref("browser.link.open_newwindow", 1);
    user_pref("browser.link.open_newwindow.restriction", 0);
    EOF

    # 2. Surgical CSS Override
    # Instead of hiding the whole toolbox, we hide ONLY the browser elements,
    # leaving the native window control buttons perfectly visible.
    cat <<EOF > "$PROFILE_DIR/chrome/userChrome.css"
    /* Hide the navigation bar, tabs, and the Firefox View button */
    #nav-bar, #PersonalToolbar, #tabbrowser-tabs, #firefox-view-button {
      visibility: collapse !important;
    }

    /* Hide leftover layout spacers and buttons */
    #tabs-newtab-button, #alltabs-button, .titlebar-spacer {
      display: none !important;
    }

    /* Enforce standard window titlebar height for the close buttons */
    #TabsToolbar {
      min-height: 38px !important;
      max-height: 38px !important;
    }
    EOF

    # Group the window into the launcher icon under GNOME Wayland & X11
    export MOZ_APP_REMOTINGNAME="zattoo-app"

    # Launch as a standard window
    exec ${pkgs.firefox}/bin/firefox \
      --profile "$PROFILE_DIR" \
      --no-remote \
      --name "zattoo-app" \
      --class "zattoo-app" \
      "https://zattoo.com/login/"
  '';

  zattooDesktop = pkgs.makeDesktopItem {
    name = "zattoo-app";
    desktopName = "Zattoo Live TV";
    comment = "Launches locked-down Zattoo app frame over SOCKS5";
    exec = "${zattooApp}/bin/zattoo-app";
    icon = ./icon.png;
    categories = [ "AudioVideo" ];
    startupWMClass = "zattoo-app";
  };
in
{
  # This tells NixOS to install both the script and the desktop shortcut system-wide
  environment.systemPackages = [
    zattooApp
    zattooDesktop
  ];
}

import QtQuick

QtObject {
  id: root

  // A Bar owns one coordinator; popup names are local to that output.
  required property var owner
  property string activePopup: ""

  function openPopup(name) {
    activePopup = name
  }

  function closePopup(name) {
    if (activePopup === name)
      activePopup = ""
  }

  function togglePopup(name) {
    activePopup = activePopup === name ? "" : name
  }
}

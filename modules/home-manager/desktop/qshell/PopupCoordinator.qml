import QtQuick

QtObject {
  id: root

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

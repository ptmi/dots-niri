import QtQuick
import qs.Commons
import qs.Services
import qs.Widgets

Text {
  id: root

  font.family: Settings.data.ui.fontDefault
  font.pointSize: Style.fontSizeM * scaling
  font.weight: Style.fontWeightMedium
  color: Color.mOnSurface
  renderType: Text.QtRendering
  font.hintingPreference: Font.PreferNoHinting
  font.kerning: true
}

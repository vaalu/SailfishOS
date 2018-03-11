import QtQuick 2.0
import Sailfish.Silica 1.0

Dialog {
    id: addEditChannel
    property string name
    property string url
    property ListModel existingChannels

    Column {
        width: parent.width

        DialogHeader {
            title: qsTr("Add (or) Edit Channels")
        }
        TextField {
            id: nameField
            width: 480
            placeholderText: "Feed Name"
            validator: RegExpValidator { regExp: /^[a-zA-Z0-9\ ]{4,}$/ }
        }
        TextField {
            id: urlField
            width: 480
            placeholderText: "Feed URL"
            //validator: IntValidator { bottom: 1; top: 10 }
        }
    }

    onDone: {
        if (result == DialogResult.Accepted) {
            name = nameField.text
            url = urlField.text
        }
        nameField.text=""
        urlField.text=""
    }
    onEntered: {
        nameField.text = name
        urlField.text = url
    }

    InteractionHintLabel {
        anchors.bottom: parent.bottom
        opacity: (nameField.focus || urlField.focus) ? 1.0 : 0.0
        Behavior on opacity { FadeAnimation {} }
        text: {
            if (nameField.focus) return "Enter alpha numeric characters only"
            if (urlField.focus) return "Enter feed url"
            return ""
        }
    }
    TouchInteractionHint {
        id: hint
        loops: Animation.Infinite
    }
}

TEMPLATE = app

TARGET = Chat

QT += qml quick widgets network sql

CONFIG += c++11

SOURCES += \
    src/main.cpp \
    src/Chat/framelesswindow.cpp \
    src/Chat/chatmanager.cpp \
    src/Chat/iteminfo.cpp \
    src/Chat/chatmessage.cpp \
    src/Network/networkmanager.cpp \
    src/Network/tcpmanager.cpp \
    src/Utility/jsonparse.cpp \
    src/Utility/friendmodel.cpp \
    src/Utility/systemtrayicon.cpp \
    src/Utility/chatapi.cpp \
    src/DataBase/databasemanager.cpp \
    ../ChatServer/src/protocol.cpp \
    src/Utility/magicfish.cpp \
    src/Utility/magicpool.cpp \
    src/Utility/imageHelper.cpp

HEADERS += \
    src/Chat/framelesswindow.h \
    src/Chat/chatmanager.h \
    src/Chat/iteminfo.h \
    src/Chat/chatmessage.h \
    src/Network/networkmanager.h \
    src/Network/tcpmanager.h \
    src/Utility/jsonparse.h \
    src/Utility/friendmodel.h \
    src/Utility/systemtrayicon.h \
    src/Utility/chatapi.h \
    src/DataBase/databasemanager.h \
    src/Utility/magicfish.h \
    src/Utility/magicpool.h \
    src/Utility/imageHelper.h

RESOURCES += \
    qml.qrc \
    image.qrc

RC_ICONS += winIcon.ico

INCLUDEPATH += \
    src \
    src/Chat \
    src/DataBase \
    src/Network \
    src/Utility \
    ../ChatServer/src

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH =

# Additional import path used to resolve QML modules just for Qt Quick Designer
QML_DESIGNER_IMPORT_PATH =

# The following define makes your compiler emit warnings if you use
# any feature of Qt which as been marked deprecated (the exact warnings
# depend on your compiler). Please consult the documentation of the
# deprecated API in order to know how to port your code away from it.
DEFINES += QT_DEPRECATED_WARNINGS

# You can also make your code fail to compile if you use deprecated APIs.
# In order to do so, uncomment the following line.
# You can also select to disable deprecated APIs only up to a certain version of Qt.
#DEFINES += QT_DISABLE_DEPRECATED_BEFORE=0x060000    # disables all the APIs deprecated before Qt 6.0.0

# Default rules for deployment.
qnx: target.path = /tmp/$${TARGET}/bin
else: unix:!android: target.path = /opt/$${TARGET}/bin
!isEmpty(target.path): INSTALLS += target

FORMS +=

DISTFILES +=

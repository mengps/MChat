import QtQuick 2.7
import QtQuick.Particles 2.0

Item
{
    id: root

    ParticleSystem
    {
        id: particleSystem
    }

    ItemParticle
    {
        id: launchParticle
        delegate: emitterDelegate
        groups: ["launch"]
        system: particleSystem
    }

    ImageParticle
    {
        id: particleImage
        source: "qrc:/image/ParticleImage/star.png"
        groups: ["sparkle"]
        system: particleSystem
        color: "#000"
        colorVariation: 0.8
        alpha: 0.3
        alphaVariation: 0.2
        rotation: 30
        rotationVariation: 60
        rotationVelocity: 90
        rotationVelocityVariation: 30
        entryEffect: ImageParticle.Scale
    }

    Component
    {
        id: emitterDelegate

        Rectangle
        {
            width: 4
            height: 4
            radius: 2
            color: Qt.rgba(Math.random() * 0.8 + 0.1, Math.random() * 0.8 + 0.1, Math.random() * 0.8 + 0.1);
        }
    }

    Emitter
    {
        height: 1
        width: parent.width
        anchors.bottom: parent.bottom
        system: particleSystem
        group: "launch"

        emitRate: 2
        maximumEmitted: 6
        size: 5
        endSize: 5
        lifeSpan: 2000
        lifeSpanVariation: 1200
        velocity: AngleDirection
        {
            angle: -90
            magnitude: root.height / 3
        }
    }

    GroupGoal
    {
        id: changer
        anchors.top: parent.top
        width: parent.width
        height: root.height / 2
        system: particleSystem
        groups: ["launch"]
        goalState: "explosion"
        jump: true
    }

    ParticleGroup
    {
        name: "explosion"
        system: particleSystem

        TrailEmitter
        {
            id: explosionEmitter
            anchors.fill: parent
            group: 'sparkle'
            follow: 'launch'
            lifeSpan: 1800
            lifeSpanVariation: 400
            emitRatePerParticle: 140
            size: 16
            sizeVariation: 2
            velocity: AngleDirection { angle: 0; angleVariation: 360; magnitude: 50 }
        }
    }
}

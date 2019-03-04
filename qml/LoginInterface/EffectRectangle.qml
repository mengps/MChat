import QtQuick 2.12
import "../index.js" as Render

Canvas
{
    id: root

    property bool init: false

    onPaint:
    {
        if (!init)
        {
            init = true;
            Render.RENDERER.init(root, Render.STRATEGY);
        }
        Render.RENDERER.drawFigure();
    }
}

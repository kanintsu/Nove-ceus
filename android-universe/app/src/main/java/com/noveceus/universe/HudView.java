package com.noveceus.universe;

import android.content.Context;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.LinearGradient;
import android.graphics.Paint;
import android.graphics.Path;
import android.graphics.RectF;
import android.graphics.Shader;
import android.graphics.Typeface;
import android.view.HapticFeedbackConstants;
import android.view.MotionEvent;
import android.view.View;

import java.util.Locale;

public final class HudView extends View {
    private final Simulation sim;
    private final UniverseRenderer renderer;
    private final Paint paint = new Paint(Paint.ANTI_ALIAS_FLAG);
    private final Paint stroke = new Paint(Paint.ANTI_ALIAS_FLAG);
    private final Paint glow = new Paint(Paint.ANTI_ALIAS_FLAG);
    private final Typeface serif = Typeface.create("serif", Typeface.NORMAL);
    private final Typeface serifBold = Typeface.create("serif", Typeface.BOLD);

    private final int gold = Color.rgb(205, 166, 87);
    private final int paleGold = Color.rgb(245, 226, 177);
    private final int cyan = Color.rgb(65, 217, 255);
    private final int teal = Color.rgb(72, 200, 171);
    private final int text = Color.rgb(239, 241, 235);
    private final int muted = Color.rgb(164, 184, 191);
    private final int panel = Color.argb(228, 7, 27, 39);

    private final RectF[] actionRects = new RectF[5];
    private final RectF[] navRects = new RectF[5];

    private float scale = 1f;
    private float offX = 0f;
    private float offY = 0f;

    private int pressedCode = -1;
    private float lastX;
    private float lastY;
    private float pinchDistance;

    public HudView(Context context, Simulation simulation, UniverseRenderer renderer) {
        super(context);
        setLayerType(View.LAYER_TYPE_SOFTWARE, null);
        sim = simulation;
        this.renderer = renderer;
        stroke.setStyle(Paint.Style.STROKE);
        stroke.setStrokeWidth(2f);
        glow.setStyle(Paint.Style.STROKE);
        glow.setStrokeWidth(5f);
        for (int i = 0; i < actionRects.length; i++) actionRects[i] = new RectF();
        for (int i = 0; i < navRects.length; i++) navRects[i] = new RectF();
    }

    @Override
    protected void onDraw(Canvas raw) {
        super.onDraw(raw);

        scale = Math.min(getWidth() / 1080f, getHeight() / 1920f);
        offX = (getWidth() - 1080f * scale) * 0.5f;
        offY = (getHeight() - 1920f * scale) * 0.5f;

        raw.save();
        raw.translate(offX, offY);
        raw.scale(scale, scale);

        drawHeader(raw);
        drawPlanetPanel(raw);
        drawEraPanel(raw);
        drawQuickActions(raw);
        drawSceneLabels(raw);
        drawStatus(raw);
        drawBottomNavigation(raw);

        raw.restore();
    }

    private void drawHeader(Canvas c) {
        paint.setTypeface(serifBold);
        paint.setTextSize(61f);
        paint.setColor(paleGold);
        paint.setShadowLayer(8f, 2f, 3f, Color.BLACK);
        c.drawText("NOVE CÉUS", 34f, 73f, paint);
        paint.clearShadowLayer();

        paint.setTypeface(serif);
        paint.setTextSize(18f);
        paint.setColor(muted);
        c.drawText("CRIAR  ·  EVOLUIR  ·  OBSERVAR", 42f, 104f, paint);

        resourceChip(c, 506f, 20f, 155f, "✦", "12.4K", "+320/min", cyan);
        resourceChip(c, 672f, 20f, 155f, "●", "3.6M", "+12.1K/min", paleGold);
        resourceChip(c, 838f, 20f, 118f, "◆", "87", "PESQ.", Color.rgb(180, 116, 255));

        panelPath(c, new RectF(970f, 20f, 1046f, 87f), 22f, panel, gold, false);
        centerText(c, "⚙", 1008f, 63f, 31f, paleGold, serifBold);
    }

    private void resourceChip(Canvas c, float x, float y, float w, String icon, String value, String rate, int accent) {
        RectF r = new RectF(x, y, x + w, y + 67f);
        panelPath(c, r, 22f, Color.argb(226, 7, 25, 37), Color.argb(210, 205, 166, 87), false);
        centerText(c, icon, x + 29f, y + 42f, 25f, accent, serifBold);
        text(c, value, x + 53f, y + 30f, 23f, text, serifBold, Paint.Align.LEFT);
        text(c, rate, x + 53f, y + 54f, 13f, muted, serif, Paint.Align.LEFT);
    }

    private void drawPlanetPanel(Canvas c) {
        RectF r = new RectF(18f, 130f, 337f, 676f);
        panelPath(c, r, 18f, panel, gold, true);

        glow.setColor(Color.argb(90, 61, 215, 255));
        glow.setShadowLayer(18f, 0f, 0f, cyan);
        c.drawCircle(72f, 191f, 42f, glow);
        glow.clearShadowLayer();

        stroke.setColor(Color.argb(220, 205, 166, 87));
        stroke.setStrokeWidth(2f);
        c.drawCircle(72f, 191f, 44f, stroke);
        centerText(c, "◎", 72f, 207f, 51f, cyan, serif);

        text(c, sim.name.toUpperCase(Locale.ROOT), 128f, 181f, 28f, paleGold, serifBold, Paint.Align.LEFT);
        text(c, "CLASSE M · MUNDO EM EVOLUÇÃO", 128f, 211f, 14f, muted, serif, Paint.Align.LEFT);
        text(c, "Um lar em formação.", 128f, 237f, 14f, Color.rgb(190, 202, 198), serif, Paint.Align.LEFT);

        float y = 286f;
        stat(c, "MASSA", String.format(Locale.US, "%.2f M⊕", sim.massEarth), y); y += 53f;
        stat(c, "ATMOSFERA", Math.round(sim.atmosphere * 100f) + "%", y); y += 53f;
        int tempColor = sim.temperature > -12f && sim.temperature < 44f ? Color.rgb(102, 240, 128) : Color.rgb(255, 115, 73);
        stat(c, "TEMPERATURA", String.format(Locale.US, "%.0f °C", sim.temperature), y, tempColor); y += 53f;
        stat(c, "ÁGUA", Math.round(sim.water * 100f) + "%", y); y += 53f;
        stat(c, "BIODIVERSIDADE", Math.round(sim.biodiversity * 3200f) + " espécies", y); y += 53f;
        stat(c, "CIVILIZAÇÃO", sim.civilizationLabel(), y); y += 53f;
        stat(c, "HABITABILIDADE", Math.round(sim.habitability() * 100f) + "%", y, teal);

        RectF details = new RectF(42f, 615f, 313f, 655f);
        panelPath(c, details, 12f, Color.argb(175, 9, 42, 56), Color.argb(150, 205, 166, 87), false);
        centerText(c, "VER DETALHES  ›", 177f, 642f, 15f, text, serifBold);
    }

    private void stat(Canvas c, String label, String value, float y) {
        stat(c, label, value, y, text);
    }

    private void stat(Canvas c, String label, String value, float y, int valueColor) {
        paint.setStyle(Paint.Style.FILL);
        paint.setColor(Color.argb(45, 255, 255, 255));
        c.drawRect(38f, y + 24f, 316f, y + 25f, paint);
        text(c, label, 43f, y, 14f, muted, serifBold, Paint.Align.LEFT);
        text(c, value, 310f, y, 17f, valueColor, serifBold, Paint.Align.RIGHT);
    }

    private void drawEraPanel(Canvas c) {
        RectF r = new RectF(741f, 129f, 1060f, 765f);
        panelPath(c, r, 18f, panel, gold, true);
        centerText(c, "JORNADA DE UM MUNDO", 900f, 170f, 22f, paleGold, serifBold);
        goldLine(c, 778f, 188f, 1024f, 188f, 1.5f, 170);

        String[] sub = {
                "A matéria se reúne", "Gravidade desperta", "Fogo e transformação",
                "A vida encontra espaço", "O início da complexidade", "Mundos verdes",
                "A diversidade cresce", "Mentes observam o céu", "Além das fronteiras"
        };

        int current = sim.eraIndex();
        for (int i = 0; i < Simulation.ERAS.length; i++) {
            float cy = 229f + i * 58f;
            boolean selected = i == current;
            boolean past = i < current;

            if (selected) {
                paint.setStyle(Paint.Style.FILL);
                paint.setColor(Color.argb(50, 44, 222, 255));
                paint.setShadowLayer(22f, 0f, 0f, cyan);
                c.drawRoundRect(new RectF(760f, cy - 26f, 1038f, cy + 25f), 14f, 14f, paint);
                paint.clearShadowLayer();
            }

            stroke.setStyle(Paint.Style.STROKE);
            stroke.setStrokeWidth(selected ? 3.5f : 2f);
            stroke.setColor(selected ? cyan : gold);
            if (selected) stroke.setShadowLayer(15f, 0f, 0f, cyan);
            c.drawCircle(780f, cy, 18f, stroke);
            stroke.clearShadowLayer();

            centerText(c, Integer.toString(i + 1), 780f, cy + 6f, 15f, selected ? cyan : (past ? paleGold : text), serifBold);
            text(c, Simulation.ERAS[i], 816f, cy - 2f, 16f, selected ? cyan : (past ? paleGold : text), selected ? serifBold : serif, Paint.Align.LEFT);
            text(c, sub[i], 816f, cy + 18f, 11.5f, muted, serif, Paint.Align.LEFT);

            if (i < Simulation.ERAS.length - 1) {
                goldLine(c, 780f, cy + 19f, 780f, cy + 39f, 1.4f, selected ? 220 : 110);
            }
        }
    }

    private void drawQuickActions(Canvas c) {
        RectF r = new RectF(23f, 709f, 298f, 1100f);
        panelPath(c, r, 17f, panel, gold, true);
        text(c, "✦  AÇÕES RÁPIDAS", 47f, 752f, 20f, paleGold, serifBold, Paint.Align.LEFT);

        String[] titles = {"ÓRBITA", "CLIMA", "VIDA", "TERRAFORMAR", "TEMPO"};
        String[] subs = {
                "Estabilizar distância", "Temperatura e atmosfera", "Semear biosfera",
                "Remodelar o mundo", "Acelerar eras"
        };

        for (int i = 0; i < 5; i++) {
            float top = 775f + i * 62f;
            RectF b = new RectF(42f, top, 278f, top + 51f);
            actionRects[i].set(b);
            boolean pressed = pressedCode == 100 + i;
            panelPath(c, b, 12f,
                    pressed ? Color.argb(235, 9, 71, 89) : Color.argb(190, 5, 39, 53),
                    pressed ? cyan : Color.argb(135, 205, 166, 87), false);

            stroke.setColor(i == 4 ? cyan : teal);
            stroke.setStrokeWidth(2f);
            c.drawCircle(69f, top + 25.5f, 17f, stroke);
            centerText(c, Integer.toString(i + 1), 69f, top + 31f, 14f, i == 4 ? cyan : teal, serifBold);

            text(c, titles[i], 96f, top + 22f, 14f, text, serifBold, Paint.Align.LEFT);
            text(c, subs[i], 96f, top + 39f, 10.5f, muted, serif, Paint.Align.LEFT);
        }
    }

    private void drawSceneLabels(Canvas c) {
        text(c, "ESTRELA MÃE", 598f, 153f, 19f, paleGold, serifBold, Paint.Align.CENTER);
        text(c, "Núcleo Luminaris", 598f, 175f, 12f, muted, serif, Paint.Align.CENTER);

        text(c, "NÉVOA DE ASTEROIDES", 520f, 355f, 15f, text, serifBold, Paint.Align.CENTER);
        text(c, "Recursos raros", 520f, 375f, 11f, muted, serif, Paint.Align.CENTER);

        text(c, "ESTAÇÃO DE PESQUISA", 618f, 478f, 14f, paleGold, serifBold, Paint.Align.CENTER);
        text(c, "Observação em andamento", 618f, 498f, 11f, muted, serif, Paint.Align.CENTER);

        text(c, sim.name, 540f, 1115f, 24f, paleGold, serifBold, Paint.Align.CENTER);
        text(c, sim.formattedAge() + "  ·  órbita " + String.format(Locale.US, "%.2f UA", sim.orbitAu),
                540f, 1144f, 13f, muted, serif, Paint.Align.CENTER);
        text(c, "TEMPO  " + (int)sim.timeScale + "x", 540f, 1172f, 14f, cyan, serifBold, Paint.Align.CENTER);
    }

    private void drawStatus(Canvas c) {
        RectF r = new RectF(210f, 1222f, 870f, 1378f);
        panelPath(c, r, 25f, Color.argb(241, 6, 27, 42), gold, true);

        stroke.setColor(cyan);
        stroke.setStrokeWidth(2f);
        stroke.setShadowLayer(18f, 0f, 0f, cyan);
        c.drawCircle(284f, 1290f, 43f, stroke);
        stroke.clearShadowLayer();
        centerText(c, "↻", 284f, 1308f, 50f, cyan, serifBold);

        text(c, "SIMULANDO…", 349f, 1261f, 17f, muted, serif, Paint.Align.LEFT);
        String era = sim.eraName().toUpperCase(Locale.ROOT) + "  ·  " + Math.round(sim.eraProgress() * 100f) + "%";
        text(c, era, 349f, 1293f, 22f, text, serifBold, Paint.Align.LEFT);

        RectF bg = new RectF(349f, 1312f, 807f, 1328f);
        paint.setStyle(Paint.Style.FILL);
        paint.setColor(Color.rgb(11, 44, 57));
        c.drawRoundRect(bg, 8f, 8f, paint);
        RectF fill = new RectF(bg.left, bg.top, bg.left + bg.width() * sim.eraProgress(), bg.bottom);
        paint.setShader(new LinearGradient(fill.left, fill.top, fill.right, fill.top,
                new int[]{Color.rgb(20, 173, 237), Color.rgb(99, 255, 231)}, null, Shader.TileMode.CLAMP));
        paint.setShadowLayer(14f, 0f, 0f, cyan);
        c.drawRoundRect(fill, 8f, 8f, paint);
        paint.clearShadowLayer();
        paint.setShader(null);

        text(c, "“" + sim.lastEvent + "”", 349f, 1353f, 12.5f, muted, serif, Paint.Align.LEFT);
    }

    private void drawBottomNavigation(Canvas c) {
        String[] names = {"CRIAR", "EVOLUIR", "ÓRBITA", "PESQUISA", "MAPA ESTELAR"};
        String[] symbols = {"✦", "❦", "◉", "⚛", "◇"};
        int[] accents = {cyan, teal, paleGold, Color.rgb(186, 128, 255), cyan};

        for (int i = 0; i < 5; i++) {
            float cx = 118f + i * 211f;
            float cy = 1515f;
            RectF hit = new RectF(cx - 82f, cy - 78f, cx + 82f, cy + 112f);
            navRects[i].set(hit);
            boolean pressed = pressedCode == 200 + i;

            glow.setStyle(Paint.Style.STROKE);
            glow.setStrokeWidth(pressed ? 5f : 3f);
            glow.setColor(pressed ? accents[i] : gold);
            glow.setShadowLayer(pressed ? 22f : 10f, 0f, 0f, pressed ? accents[i] : Color.argb(120, 205, 166, 87));
            c.drawCircle(cx, cy, 65f, glow);
            glow.clearShadowLayer();

            paint.setStyle(Paint.Style.FILL);
            paint.setColor(Color.argb(235, 5, 28, 41));
            c.drawCircle(cx, cy, 59f, paint);

            centerText(c, symbols[i], cx, cy + 17f, 47f, accents[i], serifBold);
            centerText(c, names[i], cx, cy + 92f, 17f, text, serifBold);
        }

        RectF tray = new RectF(28f, 1641f, 1052f, 1770f);
        panelPath(c, tray, 20f, Color.argb(205, 4, 22, 32), Color.argb(95, 205, 166, 87), false);

        String[] mini = {"EVENTOS", "ESPÉCIES", "CLIMA", "RECURSOS", "MISSÕES", "ARQUIVO", "CONQUISTAS", "MAIS"};
        String[] mark = {"▣", "⌁", "☁", "◆", "✧", "▤", "♕", "▦"};
        for (int i = 0; i < mini.length; i++) {
            float cx = 91f + i * 128f;
            stroke.setColor(Color.argb(150, 205, 166, 87));
            stroke.setStrokeWidth(1.5f);
            c.drawCircle(cx, 1690f, 30f, stroke);
            centerText(c, mark[i], cx, 1698f, 21f, i == 1 ? cyan : paleGold, serifBold);
            centerText(c, mini[i], cx, 1747f, 10.5f, muted, serif);
        }

        goldLine(c, 72f, 1826f, 302f, 1826f, 1f, 90);
        goldLine(c, 778f, 1826f, 1008f, 1826f, 1f, 90);
        centerText(c, "INFINITAS ORIGENS · UM SÓ FUTURO", 540f, 1834f, 13f, muted, serif);
        centerText(c, "Arraste o planeta · use dois dedos para aproximar", 540f, 1882f, 12f, Color.argb(185, 170, 194, 202), serif);
    }

    private void panelPath(Canvas c, RectF r, float radius, int fillColor, int strokeColor, boolean ornate) {
        paint.setStyle(Paint.Style.FILL);
        paint.setColor(fillColor);
        paint.setShadowLayer(16f, 0f, 5f, Color.argb(150, 0, 0, 0));
        c.drawRoundRect(r, radius, radius, paint);
        paint.clearShadowLayer();

        stroke.setStyle(Paint.Style.STROKE);
        stroke.setStrokeWidth(1.8f);
        stroke.setColor(strokeColor);
        c.drawRoundRect(r, radius, radius, stroke);

        if (ornate) {
            float k = 14f;
            Path p = new Path();
            p.moveTo(r.left + 7f, r.top + 32f); p.lineTo(r.left + 7f, r.top + 9f); p.lineTo(r.left + 32f, r.top + 9f);
            p.moveTo(r.right - 7f, r.top + 32f); p.lineTo(r.right - 7f, r.top + 9f); p.lineTo(r.right - 32f, r.top + 9f);
            p.moveTo(r.left + 7f, r.bottom - 32f); p.lineTo(r.left + 7f, r.bottom - 9f); p.lineTo(r.left + 32f, r.bottom - 9f);
            p.moveTo(r.right - 7f, r.bottom - 32f); p.lineTo(r.right - 7f, r.bottom - 9f); p.lineTo(r.right - 32f, r.bottom - 9f);
            stroke.setStrokeWidth(2.6f);
            stroke.setColor(Color.argb(225, Color.red(strokeColor), Color.green(strokeColor), Color.blue(strokeColor)));
            c.drawPath(p, stroke);

            paint.setStyle(Paint.Style.FILL);
            paint.setColor(strokeColor);
            c.save();
            c.rotate(45f, r.centerX(), r.top + 5f);
            c.drawRect(r.centerX() - k / 2f, r.top + 5f - k / 2f, r.centerX() + k / 2f, r.top + 5f + k / 2f, paint);
            c.restore();
        }
    }

    private void goldLine(Canvas c, float x1, float y1, float x2, float y2, float width, int alpha) {
        stroke.setStyle(Paint.Style.STROKE);
        stroke.setStrokeWidth(width);
        stroke.setColor(Color.argb(alpha, 205, 166, 87));
        c.drawLine(x1, y1, x2, y2, stroke);
    }

    private void text(Canvas c, String s, float x, float y, float size, int color, Typeface face, Paint.Align align) {
        paint.setStyle(Paint.Style.FILL);
        paint.setTypeface(face);
        paint.setTextSize(size);
        paint.setColor(color);
        paint.setTextAlign(align);
        c.drawText(s, x, y, paint);
    }

    private void centerText(Canvas c, String s, float x, float baseline, float size, int color, Typeface face) {
        text(c, s, x, baseline, size, color, face, Paint.Align.CENTER);
    }

    @Override
    public boolean onTouchEvent(MotionEvent e) {
        float x = (e.getX() - offX) / Math.max(0.001f, scale);
        float y = (e.getY() - offY) / Math.max(0.001f, scale);

        if (e.getPointerCount() >= 2) {
            float dx = e.getX(0) - e.getX(1);
            float dy = e.getY(0) - e.getY(1);
            float dist = (float)Math.sqrt(dx * dx + dy * dy);
            if (e.getActionMasked() == MotionEvent.ACTION_POINTER_DOWN) {
                pinchDistance = dist;
            } else if (e.getActionMasked() == MotionEvent.ACTION_MOVE && pinchDistance > 0f) {
                float delta = dist - pinchDistance;
                renderer.cameraDistance = clamp(renderer.cameraDistance - delta * 0.008f, 8.5f, 18.5f);
                pinchDistance = dist;
            }
            return true;
        }

        switch (e.getActionMasked()) {
            case MotionEvent.ACTION_DOWN:
                pressedCode = hitCode(x, y);
                lastX = x;
                lastY = y;
                invalidate();
                return true;

            case MotionEvent.ACTION_MOVE:
                if (pressedCode < 0) {
                    float dx = x - lastX;
                    float dy = y - lastY;
                    renderer.yaw -= dx * 0.20f;
                    renderer.pitch = clamp(renderer.pitch + dy * 0.12f, -50f, 50f);
                    lastX = x;
                    lastY = y;
                }
                return true;

            case MotionEvent.ACTION_UP:
                int released = hitCode(x, y);
                int selected = pressedCode;
                pressedCode = -1;
                if (selected >= 0 && released == selected) {
                    performHapticFeedback(HapticFeedbackConstants.KEYBOARD_TAP);
                    execute(selected);
                }
                invalidate();
                return true;

            case MotionEvent.ACTION_CANCEL:
                pressedCode = -1;
                invalidate();
                return true;
        }
        return true;
    }

    private int hitCode(float x, float y) {
        for (int i = 0; i < actionRects.length; i++) if (actionRects[i].contains(x, y)) return 100 + i;
        for (int i = 0; i < navRects.length; i++) if (navRects[i].contains(x, y)) return 200 + i;
        return -1;
    }

    private void execute(int code) {
        switch (code) {
            case 100: sim.adjustOrbit(); break;
            case 101: sim.modifyClimate(); break;
            case 102: sim.introduceLife(); break;
            case 103: sim.terraform(); break;
            case 104: sim.cycleTime(); break;
            case 200: sim.newWorld(); renderer.yaw = -18f; renderer.pitch = 12f; break;
            case 201: sim.evolve(); break;
            case 202: sim.adjustOrbit(); break;
            case 203: sim.research(); break;
            case 204:
                renderer.systemView = !renderer.systemView;
                sim.lastEvent = renderer.systemView
                        ? "Mapa estelar aberto: visão ampliada do sistema."
                        : "Retornando à órbita de " + sim.name + ".";
                break;
        }
    }

    private static float clamp(float v, float min, float max) {
        return Math.max(min, Math.min(max, v));
    }
}

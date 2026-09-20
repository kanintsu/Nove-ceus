package com.noveceus.universe;

import android.opengl.GLES20;
import android.opengl.GLSurfaceView;
import android.opengl.Matrix;

import java.nio.ByteBuffer;
import java.nio.ByteOrder;
import java.nio.FloatBuffer;
import java.nio.ShortBuffer;
import java.util.Random;

import javax.microedition.khronos.egl.EGLConfig;
import javax.microedition.khronos.opengles.GL10;

public final class UniverseRenderer implements GLSurfaceView.Renderer {
    private final Simulation sim;

    private FloatBuffer spherePos;
    private FloatBuffer sphereNormal;
    private ShortBuffer sphereIndex;
    private int sphereIndexCount;

    private FloatBuffer stars;
    private int starCount;

    private FloatBuffer orbit;
    private int orbitCount;

    private int bodyProgram;
    private int starProgram;
    private int lineProgram;

    private int bodyAPos;
    private int bodyANormal;
    private int bodyUMvp;
    private int bodyUModel;
    private int bodyUType;
    private int bodyUTime;
    private int bodyUWater;
    private int bodyUTemp;
    private int bodyULife;
    private int bodyUCiv;
    private int bodyUSeed;

    private int starAPos;
    private int starUTime;
    private int lineAPos;
    private int lineUMvp;
    private int lineUColor;

    private final float[] projection = new float[16];
    private final float[] view = new float[16];
    private final float[] model = new float[16];
    private final float[] mv = new float[16];
    private final float[] mvp = new float[16];

    public volatile float yaw = -18f;
    public volatile float pitch = 12f;
    public volatile float cameraDistance = 10.8f;
    public volatile boolean systemView = false;

    private long startNanos;

    public UniverseRenderer(Simulation simulation) {
        this.sim = simulation;
    }

    @Override
    public void onSurfaceCreated(GL10 gl, EGLConfig config) {
        GLES20.glClearColor(0.003f, 0.008f, 0.025f, 1f);
        GLES20.glEnable(GLES20.GL_DEPTH_TEST);
        GLES20.glEnable(GLES20.GL_CULL_FACE);
        GLES20.glCullFace(GLES20.GL_BACK);
        GLES20.glEnable(GLES20.GL_BLEND);
        GLES20.glBlendFunc(GLES20.GL_SRC_ALPHA, GLES20.GL_ONE_MINUS_SRC_ALPHA);

        buildSphere(72, 108);
        buildStars(900);
        buildOrbit(160);

        bodyProgram = linkProgram(BODY_VERTEX, BODY_FRAGMENT);
        starProgram = linkProgram(STAR_VERTEX, STAR_FRAGMENT);
        lineProgram = linkProgram(LINE_VERTEX, LINE_FRAGMENT);

        bodyAPos = GLES20.glGetAttribLocation(bodyProgram, "aPos");
        bodyANormal = GLES20.glGetAttribLocation(bodyProgram, "aNormal");
        bodyUMvp = GLES20.glGetUniformLocation(bodyProgram, "uMvp");
        bodyUModel = GLES20.glGetUniformLocation(bodyProgram, "uModel");
        bodyUType = GLES20.glGetUniformLocation(bodyProgram, "uType");
        bodyUTime = GLES20.glGetUniformLocation(bodyProgram, "uTime");
        bodyUWater = GLES20.glGetUniformLocation(bodyProgram, "uWater");
        bodyUTemp = GLES20.glGetUniformLocation(bodyProgram, "uTemp");
        bodyULife = GLES20.glGetUniformLocation(bodyProgram, "uLife");
        bodyUCiv = GLES20.glGetUniformLocation(bodyProgram, "uCiv");
        bodyUSeed = GLES20.glGetUniformLocation(bodyProgram, "uSeed");

        starAPos = GLES20.glGetAttribLocation(starProgram, "aPos");
        starUTime = GLES20.glGetUniformLocation(starProgram, "uTime");
        lineAPos = GLES20.glGetAttribLocation(lineProgram, "aPos");
        lineUMvp = GLES20.glGetUniformLocation(lineProgram, "uMvp");
        lineUColor = GLES20.glGetUniformLocation(lineProgram, "uColor");

        startNanos = System.nanoTime();
    }

    @Override
    public void onSurfaceChanged(GL10 gl, int width, int height) {
        GLES20.glViewport(0, 0, width, height);
        float aspect = width / (float)Math.max(1, height);
        Matrix.perspectiveM(projection, 0, 35f, aspect, 0.1f, 120f);
    }

    @Override
    public void onDrawFrame(GL10 gl) {
        GLES20.glClear(GLES20.GL_COLOR_BUFFER_BIT | GLES20.GL_DEPTH_BUFFER_BIT);

        float t = (System.nanoTime() - startNanos) * 1e-9f;
        float dist = systemView ? Math.max(15f, cameraDistance + 4.5f) : cameraDistance;
        float lookY = systemView ? 1.1f : -0.35f;

        Matrix.setLookAtM(view, 0, 0f, 0.1f, -dist, 0f, lookY, 0f, 0f, 1f, 0f);

        drawStars(t);
        drawSun(t);
        drawOrbitRings(t);
        drawPlanet(t);
        drawMoon(t);
        drawDistantBodies(t);
    }

    private void drawStars(float t) {
        GLES20.glDisable(GLES20.GL_DEPTH_TEST);
        GLES20.glUseProgram(starProgram);
        stars.position(0);
        GLES20.glEnableVertexAttribArray(starAPos);
        GLES20.glVertexAttribPointer(starAPos, 3, GLES20.GL_FLOAT, false, 3 * 4, stars);
        GLES20.glUniform1f(starUTime, t);
        GLES20.glDrawArrays(GLES20.GL_POINTS, 0, starCount);
        GLES20.glDisableVertexAttribArray(starAPos);
        GLES20.glEnable(GLES20.GL_DEPTH_TEST);
    }

    private void drawPlanet(float t) {
        Matrix.setIdentityM(model, 0);
        Matrix.translateM(model, 0, 0f, -1.0f, 0f);
        Matrix.rotateM(model, 0, pitch, 1f, 0f, 0f);
        Matrix.rotateM(model, 0, yaw + t * 2.0f, 0f, 1f, 0f);
        Matrix.scaleM(model, 0, 3.15f, 3.15f, 3.15f);
        drawSphere(model, 0, t);

        GLES20.glEnable(GLES20.GL_BLEND);
        GLES20.glBlendFunc(GLES20.GL_SRC_ALPHA, GLES20.GL_ONE_MINUS_SRC_ALPHA);
        Matrix.setIdentityM(model, 0);
        Matrix.translateM(model, 0, 0f, -1.0f, 0f);
        Matrix.rotateM(model, 0, pitch * 0.7f, 1f, 0f, 0f);
        Matrix.rotateM(model, 0, yaw + t * 4.5f, 0f, 1f, 0f);
        Matrix.scaleM(model, 0, 3.20f, 3.20f, 3.20f);
        drawSphere(model, 1, t);

        GLES20.glBlendFunc(GLES20.GL_SRC_ALPHA, GLES20.GL_ONE);
        Matrix.setIdentityM(model, 0);
        Matrix.translateM(model, 0, 0f, -1.0f, 0f);
        Matrix.scaleM(model, 0, 3.42f, 3.42f, 3.42f);
        drawSphere(model, 2, t);
        GLES20.glBlendFunc(GLES20.GL_SRC_ALPHA, GLES20.GL_ONE_MINUS_SRC_ALPHA);
    }

    private void drawMoon(float t) {
        float angle = t * 0.19f;
        float x = 4.15f * (float)Math.cos(angle);
        float z = 1.2f + 1.2f * (float)Math.sin(angle);
        float y = -0.15f + 0.35f * (float)Math.sin(angle * 0.73f);

        Matrix.setIdentityM(model, 0);
        Matrix.translateM(model, 0, x, y, z);
        Matrix.rotateM(model, 0, t * 11f, 0f, 1f, 0f);
        Matrix.scaleM(model, 0, 0.72f, 0.72f, 0.72f);
        drawSphere(model, 3, t);
    }

    private void drawSun(float t) {
        GLES20.glBlendFunc(GLES20.GL_SRC_ALPHA, GLES20.GL_ONE);

        Matrix.setIdentityM(model, 0);
        Matrix.translateM(model, 0, 2.85f, 5.05f, 5.0f);
        Matrix.scaleM(model, 0, 1.55f, 1.55f, 1.55f);
        drawSphere(model, 4, t);

        Matrix.setIdentityM(model, 0);
        Matrix.translateM(model, 0, 2.85f, 5.05f, 5.0f);
        Matrix.scaleM(model, 0, 2.05f, 2.05f, 2.05f);
        drawSphere(model, 5, t);

        GLES20.glBlendFunc(GLES20.GL_SRC_ALPHA, GLES20.GL_ONE_MINUS_SRC_ALPHA);
    }

    private void drawDistantBodies(float t) {
        Matrix.setIdentityM(model, 0);
        Matrix.translateM(model, 0, -3.6f, 4.3f, 8.5f);
        Matrix.rotateM(model, 0, t * 2.2f, 0f, 1f, 0f);
        Matrix.scaleM(model, 0, 0.78f, 0.78f, 0.78f);
        drawSphere(model, 6, t);

        Matrix.setIdentityM(model, 0);
        Matrix.translateM(model, 0, 4.1f, -4.0f, 9.5f);
        Matrix.rotateM(model, 0, t * 1.5f, 0f, 1f, 0f);
        Matrix.scaleM(model, 0, 1.08f, 1.08f, 1.08f);
        drawSphere(model, 7, t);
    }

    private void drawOrbitRings(float t) {
        GLES20.glUseProgram(lineProgram);
        orbit.position(0);
        GLES20.glEnableVertexAttribArray(lineAPos);
        GLES20.glVertexAttribPointer(lineAPos, 3, GLES20.GL_FLOAT, false, 3 * 4, orbit);

        drawRing(0f, -1f, 0f, 4.15f, 76f, 0f, 14f, 0.16f, 0.63f, 0.95f, 0.26f);
        drawRing(0f, -1f, 0f, 4.65f, 82f, 24f, 0f, 0.86f, 0.68f, 0.30f, 0.18f);
        drawRing(0f, -1f, 0f, 5.28f, 69f, -16f, -8f, 0.18f, 0.72f, 0.82f, 0.11f);

        GLES20.glDisableVertexAttribArray(lineAPos);
    }

    private void drawRing(float tx, float ty, float tz, float scale,
                          float rx, float ry, float rz,
                          float r, float g, float b, float a) {
        Matrix.setIdentityM(model, 0);
        Matrix.translateM(model, 0, tx, ty, tz);
        Matrix.rotateM(model, 0, rx, 1f, 0f, 0f);
        Matrix.rotateM(model, 0, ry, 0f, 1f, 0f);
        Matrix.rotateM(model, 0, rz, 0f, 0f, 1f);
        Matrix.scaleM(model, 0, scale, scale, scale);
        makeMvp(model);
        GLES20.glUniformMatrix4fv(lineUMvp, 1, false, mvp, 0);
        GLES20.glUniform4f(lineUColor, r, g, b, a);
        GLES20.glDrawArrays(GLES20.GL_LINE_LOOP, 0, orbitCount);
    }

    private void drawSphere(float[] modelMatrix, int type, float t) {
        GLES20.glUseProgram(bodyProgram);
        spherePos.position(0);
        sphereNormal.position(0);
        sphereIndex.position(0);

        GLES20.glEnableVertexAttribArray(bodyAPos);
        GLES20.glEnableVertexAttribArray(bodyANormal);
        GLES20.glVertexAttribPointer(bodyAPos, 3, GLES20.GL_FLOAT, false, 3 * 4, spherePos);
        GLES20.glVertexAttribPointer(bodyANormal, 3, GLES20.GL_FLOAT, false, 3 * 4, sphereNormal);

        makeMvp(modelMatrix);
        GLES20.glUniformMatrix4fv(bodyUMvp, 1, false, mvp, 0);
        GLES20.glUniformMatrix4fv(bodyUModel, 1, false, modelMatrix, 0);
        GLES20.glUniform1i(bodyUType, type);
        GLES20.glUniform1f(bodyUTime, t);
        GLES20.glUniform1f(bodyUWater, sim.water);
        GLES20.glUniform1f(bodyUTemp, sim.temperature);
        GLES20.glUniform1f(bodyULife, sim.biodiversity);
        GLES20.glUniform1f(bodyUCiv, sim.civilization);
        GLES20.glUniform1f(bodyUSeed, sim.seed);

        if (type == 1 || type == 2 || type == 5) {
            GLES20.glDisable(GLES20.GL_CULL_FACE);
            GLES20.glDepthMask(false);
        } else {
            GLES20.glEnable(GLES20.GL_CULL_FACE);
            GLES20.glDepthMask(true);
        }

        GLES20.glDrawElements(GLES20.GL_TRIANGLES, sphereIndexCount, GLES20.GL_UNSIGNED_SHORT, sphereIndex);

        GLES20.glDepthMask(true);
        GLES20.glEnable(GLES20.GL_CULL_FACE);
        GLES20.glDisableVertexAttribArray(bodyAPos);
        GLES20.glDisableVertexAttribArray(bodyANormal);
    }

    private void makeMvp(float[] modelMatrix) {
        Matrix.multiplyMM(mv, 0, view, 0, modelMatrix, 0);
        Matrix.multiplyMM(mvp, 0, projection, 0, mv, 0);
    }

    private void buildSphere(int stacks, int slices) {
        int verts = (stacks + 1) * (slices + 1);
        float[] pos = new float[verts * 3];
        float[] nor = new float[verts * 3];
        int p = 0;

        for (int i = 0; i <= stacks; i++) {
            float v = i / (float)stacks;
            float phi = (float)Math.PI * v;
            float sy = (float)Math.cos(phi);
            float sr = (float)Math.sin(phi);

            for (int j = 0; j <= slices; j++) {
                float u = j / (float)slices;
                float theta = (float)(Math.PI * 2.0) * u;
                float sx = sr * (float)Math.cos(theta);
                float sz = sr * (float)Math.sin(theta);
                pos[p] = nor[p] = sx; p++;
                pos[p] = nor[p] = sy; p++;
                pos[p] = nor[p] = sz; p++;
            }
        }

        short[] ind = new short[stacks * slices * 6];
        int k = 0;
        for (int i = 0; i < stacks; i++) {
            for (int j = 0; j < slices; j++) {
                short a = (short)(i * (slices + 1) + j);
                short b = (short)(a + slices + 1);
                short c = (short)(a + 1);
                short d = (short)(b + 1);
                ind[k++] = a; ind[k++] = b; ind[k++] = c;
                ind[k++] = c; ind[k++] = b; ind[k++] = d;
            }
        }

        spherePos = floatBuffer(pos);
        sphereNormal = floatBuffer(nor);
        sphereIndex = shortBuffer(ind);
        sphereIndexCount = ind.length;
    }

    private void buildStars(int count) {
        float[] data = new float[count * 3];
        Random rng = new Random(99173L);
        for (int i = 0; i < count; i++) {
            data[i * 3] = -1f + rng.nextFloat() * 2f;
            data[i * 3 + 1] = -1f + rng.nextFloat() * 2f;
            data[i * 3 + 2] = rng.nextFloat();
        }
        stars = floatBuffer(data);
        starCount = count;
    }

    private void buildOrbit(int count) {
        float[] data = new float[count * 3];
        for (int i = 0; i < count; i++) {
            float a = (float)(Math.PI * 2.0) * i / count;
            data[i * 3] = (float)Math.cos(a);
            data[i * 3 + 1] = 0f;
            data[i * 3 + 2] = (float)Math.sin(a);
        }
        orbit = floatBuffer(data);
        orbitCount = count;
    }

    private static FloatBuffer floatBuffer(float[] values) {
        ByteBuffer bb = ByteBuffer.allocateDirect(values.length * 4).order(ByteOrder.nativeOrder());
        FloatBuffer fb = bb.asFloatBuffer();
        fb.put(values).position(0);
        return fb;
    }

    private static ShortBuffer shortBuffer(short[] values) {
        ByteBuffer bb = ByteBuffer.allocateDirect(values.length * 2).order(ByteOrder.nativeOrder());
        ShortBuffer sb = bb.asShortBuffer();
        sb.put(values).position(0);
        return sb;
    }

    private static int linkProgram(String vertex, String fragment) {
        int vs = compileShader(GLES20.GL_VERTEX_SHADER, vertex);
        int fs = compileShader(GLES20.GL_FRAGMENT_SHADER, fragment);
        int program = GLES20.glCreateProgram();
        GLES20.glAttachShader(program, vs);
        GLES20.glAttachShader(program, fs);
        GLES20.glLinkProgram(program);
        int[] ok = new int[1];
        GLES20.glGetProgramiv(program, GLES20.GL_LINK_STATUS, ok, 0);
        if (ok[0] == 0) {
            String log = GLES20.glGetProgramInfoLog(program);
            GLES20.glDeleteProgram(program);
            throw new RuntimeException("OpenGL program link failed: " + log);
        }
        GLES20.glDeleteShader(vs);
        GLES20.glDeleteShader(fs);
        return program;
    }

    private static int compileShader(int type, String source) {
        int shader = GLES20.glCreateShader(type);
        GLES20.glShaderSource(shader, source);
        GLES20.glCompileShader(shader);
        int[] ok = new int[1];
        GLES20.glGetShaderiv(shader, GLES20.GL_COMPILE_STATUS, ok, 0);
        if (ok[0] == 0) {
            String log = GLES20.glGetShaderInfoLog(shader);
            GLES20.glDeleteShader(shader);
            throw new RuntimeException("OpenGL shader compile failed: " + log);
        }
        return shader;
    }

    private static final String BODY_VERTEX =
            "uniform mat4 uMvp;\n" +
            "uniform mat4 uModel;\n" +
            "attribute vec3 aPos;\n" +
            "attribute vec3 aNormal;\n" +
            "varying vec3 vPos;\n" +
            "varying vec3 vNormal;\n" +
            "varying vec3 vWorld;\n" +
            "void main(){\n" +
            "  vPos=aPos;\n" +
            "  vNormal=normalize(mat3(uModel)*aNormal);\n" +
            "  vWorld=(uModel*vec4(aPos,1.0)).xyz;\n" +
            "  gl_Position=uMvp*vec4(aPos,1.0);\n" +
            "}\n";

    private static final String BODY_FRAGMENT =
            "precision highp float;\n" +
            "uniform int uType;\n" +
            "uniform float uTime;\n" +
            "uniform float uWater;\n" +
            "uniform float uTemp;\n" +
            "uniform float uLife;\n" +
            "uniform float uCiv;\n" +
            "uniform float uSeed;\n" +
            "varying vec3 vPos;\n" +
            "varying vec3 vNormal;\n" +
            "varying vec3 vWorld;\n" +
            "float h(vec3 p){return fract(sin(dot(p,vec3(127.1,311.7,74.7)))*43758.5453);}\n" +
            "float n3(vec3 p){\n" +
            " vec3 i=floor(p), f=fract(p); f=f*f*(3.0-2.0*f);\n" +
            " float a=h(i),b=h(i+vec3(1,0,0)),c=h(i+vec3(0,1,0)),d=h(i+vec3(1,1,0));\n" +
            " float e=h(i+vec3(0,0,1)),f1=h(i+vec3(1,0,1)),g=h(i+vec3(0,1,1)),hh=h(i+vec3(1,1,1));\n" +
            " return mix(mix(mix(a,b,f.x),mix(c,d,f.x),f.y),mix(mix(e,f1,f.x),mix(g,hh,f.x),f.y),f.z);\n" +
            "}\n" +
            "float fbm(vec3 p){float v=0.0;float a=.5;for(int i=0;i<5;i++){v+=n3(p)*a;p=p*2.03+vec3(7.1,11.7,5.3);a*=.5;}return v;}\n" +
            "void main(){\n" +
            " vec3 p=normalize(vPos);\n" +
            " vec3 N=normalize(vNormal);\n" +
            " vec3 L=normalize(vec3(.42,.72,-.48));\n" +
            " float ndl=dot(N,L);\n" +
            " float daylight=clamp(ndl*.78+.30,0.0,1.0);\n" +
            " float seed=fract(uSeed*.000173)*9.0;\n" +
            " if(uType==0){\n" +
            "   float terrain=fbm(p*2.85+seed)*.75+fbm(p*8.3+seed*.3)*.29-abs(fbm(p*14.0+2.4)-.5)*.10;\n" +
            "   float sea=mix(.68,.46,clamp(uWater,0.0,1.0));\n" +
            "   float land=smoothstep(sea,sea+.045,terrain);\n" +
            "   float depth=clamp((sea-terrain)*7.0,0.0,1.0);\n" +
            "   vec3 ocean=mix(vec3(.02,.34,.48),vec3(.004,.035,.11),depth);\n" +
            "   float alt=clamp((terrain-sea)*5.3,0.0,1.0);\n" +
            "   vec3 dry=mix(vec3(.10,.23,.11),vec3(.38,.28,.16),alt);\n" +
            "   float moisture=clamp(uWater*1.2+fbm(p*6.0)*.35-.22,0.0,1.0);\n" +
            "   float veg=clamp(uLife*1.65*moisture*(1.0-alt),0.0,1.0);\n" +
            "   vec3 fertile=mix(vec3(.03,.14,.07),vec3(.16,.48,.12),fbm(p*7.0));\n" +
            "   vec3 landCol=mix(dry,fertile,veg);\n" +
            "   landCol=mix(landCol,vec3(.30,.28,.27),smoothstep(.56,.90,alt));\n" +
            "   float heat=clamp((uTemp-55.0)/155.0,0.0,1.0);\n" +
            "   float lava=smoothstep(.83,.94,fbm(p*22.0+4.0))*heat*land;\n" +
            "   landCol=mix(landCol,vec3(1.4,.13,.01),lava);\n" +
            "   float lat=abs(p.y); float heatNorm=clamp((uTemp+35.0)/115.0,0.0,1.0);\n" +
            "   float ice=smoothstep(.70-heatNorm*.16,.95-heatNorm*.04,lat);\n" +
            "   vec3 col=mix(ocean,landCol,land);\n" +
            "   col=mix(col,vec3(.86,.92,.98),ice*.88);\n" +
            "   col*=.23+daylight*.94;\n" +
            "   float city=smoothstep(.78,.93,fbm(p*46.0+seed*1.9))*land*uCiv*clamp(-ndl*3.0,0.0,1.0);\n" +
            "   col+=vec3(1.7,.70,.14)*city*2.3;\n" +
            "   float rim=pow(1.0-clamp(abs(N.z),0.0,1.0),2.2); col+=vec3(.03,.15,.32)*rim*.32;\n" +
            "   gl_FragColor=vec4(col,1.0); return;\n" +
            " }\n" +
            " if(uType==1){\n" +
            "   float q=fbm(p*5.2+seed+vec3(uTime*.018,0.0,uTime*.012));\n" +
            "   float alpha=smoothstep(.57,.77,q)*.64;\n" +
            "   vec3 col=vec3(.88,.95,1.0)*(.52+daylight*.55);\n" +
            "   gl_FragColor=vec4(col,alpha);return;\n" +
            " }\n" +
            " if(uType==2){\n" +
            "   float rim=pow(1.0-clamp(abs(N.z),0.0,1.0),2.3);\n" +
            "   gl_FragColor=vec4(vec3(.08,.55,1.0)*(1.2+rim*1.8),rim*.23);return;\n" +
            " }\n" +
            " if(uType==3){\n" +
            "   float q=fbm(p*7.0+3.0); vec3 c=mix(vec3(.10,.11,.13),vec3(.52,.52,.50),q); c*=.20+daylight*.82;\n" +
            "   gl_FragColor=vec4(c,1.0);return;\n" +
            " }\n" +
            " if(uType==4){\n" +
            "   float q=fbm(p*8.0+vec3(uTime*.08,0.0,0.0)); vec3 c=mix(vec3(1.5,.28,.02),vec3(1.8,1.25,.56),q);\n" +
            "   gl_FragColor=vec4(c,.96);return;\n" +
            " }\n" +
            " if(uType==5){\n" +
            "   float rim=pow(1.0-clamp(abs(N.z),0.0,1.0),1.5); gl_FragColor=vec4(1.0,.52,.10,rim*.08);return;\n" +
            " }\n" +
            " if(uType==6){float q=fbm(p*5.0+1.3);vec3 c=mix(vec3(.06,.11,.19),vec3(.20,.29,.39),q);gl_FragColor=vec4(c*(.2+daylight*.75),1.0);return;}\n" +
            " float q=fbm(p*4.0+4.4);vec3 c=mix(vec3(.17,.06,.04),vec3(.48,.27,.11),q);gl_FragColor=vec4(c*(.2+daylight*.72),1.0);\n" +
            "}\n";

    private static final String STAR_VERTEX =
            "attribute vec3 aPos;\n" +
            "uniform float uTime;\n" +
            "varying float vB;\n" +
            "void main(){gl_Position=vec4(aPos.xy,0.98,1.0);gl_PointSize=1.0+4.0*fract(aPos.z*17.7);vB=.35+.65*abs(sin(uTime*.4+aPos.z*50.0));}\n";

    private static final String STAR_FRAGMENT =
            "precision mediump float;varying float vB;void main(){vec2 q=gl_PointCoord-.5;float d=dot(q,q);if(d>.25)discard;float a=smoothstep(.25,0.0,d);gl_FragColor=vec4(.72,.84,1.0,a*vB);}\n";

    private static final String LINE_VERTEX =
            "uniform mat4 uMvp;attribute vec3 aPos;void main(){gl_Position=uMvp*vec4(aPos,1.0);}\n";

    private static final String LINE_FRAGMENT =
            "precision mediump float;uniform vec4 uColor;void main(){gl_FragColor=uColor;}\n";
}

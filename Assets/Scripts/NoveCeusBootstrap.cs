using System;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.EventSystems;
using UnityEngine.UI;

namespace NoveCeus
{
    public sealed class NoveCeusBootstrap : MonoBehaviour
    {
        static bool booted;

        readonly Color gold = new Color(0.80f, 0.64f, 0.32f, 1f);
        readonly Color paleGold = new Color(0.96f, 0.88f, 0.68f, 1f);
        readonly Color cyan = new Color(0.18f, 0.82f, 1f, 1f);
        readonly Color teal = new Color(0.18f, 0.74f, 0.64f, 1f);
        readonly Color panel = new Color(0.025f, 0.075f, 0.11f, 0.93f);
        readonly Color panelSoft = new Color(0.04f, 0.11f, 0.15f, 0.88f);
        readonly Color textMain = new Color(0.94f, 0.94f, 0.90f, 1f);
        readonly Color textMuted = new Color(0.66f, 0.74f, 0.77f, 1f);

        Camera cam;
        Transform planetRoot;
        Transform planetSurface;
        Transform cloudSphere;
        Transform moon;
        Transform star;
        Material planetMat;
        Material cloudMat;
        Material atmosphereMat;
        Material starMat;
        UniverseSimulation sim;

        Canvas canvas;
        Font font;
        Text worldNameText;
        Text massText;
        Text atmosphereText;
        Text temperatureText;
        Text waterText;
        Text biodiversityText;
        Text civilizationText;
        Text ageText;
        Text eventText;
        Text statusText;
        Text speedText;
        Text habitabilityText;
        Text moonText;
        Text resourceText;
        Text mapModeText;
        Image progressFill;
        readonly List<Text> eraRows = new List<Text>();
        readonly List<Image> eraDots = new List<Image>();

        bool mapView;
        float refreshTimer;
        float cameraTargetZ = -12.7f;
        Vector2 lastPointer;

        [RuntimeInitializeOnLoadMethod(RuntimeInitializeLoadType.AfterSceneLoad)]
        static void AutoBoot()
        {
            if (booted) return;
            booted = true;
            var root = new GameObject("NOVE_CEUS_RUNTIME");
            DontDestroyOnLoad(root);
            root.AddComponent<NoveCeusBootstrap>();
        }

        void Awake()
        {
            Application.targetFrameRate = 60;
            Screen.orientation = ScreenOrientation.Portrait;

            sim = UniverseSimulation.Instance;
            if (sim == null)
            {
                var simGo = new GameObject("UniverseSimulation");
                simGo.transform.SetParent(transform);
                sim = simGo.AddComponent<UniverseSimulation>();
            }

            font = Resources.GetBuiltinResource<Font>("LegacyRuntime.ttf");
            if (font == null)
                font = Resources.GetBuiltinResource<Font>("Arial.ttf");

            BuildScene();
            BuildUI();
            RefreshAll();
        }

        void BuildScene()
        {
            RenderSettings.ambientLight = new Color(0.035f, 0.055f, 0.095f);
            RenderSettings.fog = false;

            var cameraGo = new GameObject("Cosmic Camera");
            cameraGo.transform.SetParent(transform);
            cam = cameraGo.AddComponent<Camera>();
            cam.clearFlags = CameraClearFlags.SolidColor;
            cam.backgroundColor = new Color(0.0035f, 0.008f, 0.024f);
            cam.fieldOfView = 36f;
            cam.nearClipPlane = 0.05f;
            cam.farClipPlane = 220f;
            cam.transform.position = new Vector3(0f, 0.05f, cameraTargetZ);
            cam.transform.LookAt(Vector3.zero);

            BuildStarfield();
            BuildNebula(new Vector3(-4.2f, 4.9f, 9f), new Color(0.12f, 0.35f, 0.75f, 0.18f), 46, 6.8f);
            BuildNebula(new Vector3(4.7f, 2.5f, 12f), new Color(0.45f, 0.13f, 0.65f, 0.12f), 34, 5.4f);

            var sunLightGo = new GameObject("Star Directional Light");
            sunLightGo.transform.SetParent(transform);
            var sunLight = sunLightGo.AddComponent<Light>();
            sunLight.type = LightType.Directional;
            sunLight.color = new Color(1f, 0.87f, 0.66f);
            sunLight.intensity = 1.25f;
            sunLightGo.transform.rotation = Quaternion.Euler(37f, -31f, 0f);

            var rimLightGo = new GameObject("Planet Rim Light");
            rimLightGo.transform.SetParent(transform);
            var rimLight = rimLightGo.AddComponent<Light>();
            rimLight.type = LightType.Point;
            rimLight.range = 24f;
            rimLight.intensity = 1.6f;
            rimLight.color = new Color(0.1f, 0.48f, 1f);
            rimLightGo.transform.position = new Vector3(-4.2f, -1.8f, -2.8f);

            BuildStar();
            BuildPlanet();
            BuildMoon();
            BuildAsteroidBelt();
            BuildOrbitalStation(new Vector3(-4.25f, -2.4f, 1.2f), 1.18f);
            BuildOrbitalStation(new Vector3(4.05f, 2.0f, 2.7f), 0.82f);
            BuildDistantPlanet(new Vector3(-3.4f, 4.7f, 4.7f), 0.62f, new Color(0.17f, 0.25f, 0.39f));
            BuildDistantPlanet(new Vector3(4.0f, -4.1f, 6.4f), 0.95f, new Color(0.30f, 0.17f, 0.13f));
        }

        void BuildStarfield()
        {
            var go = new GameObject("Procedural Starfield");
            go.transform.SetParent(transform);
            var ps = go.AddComponent<ParticleSystem>();
            var main = ps.main;
            main.loop = false;
            main.playOnAwake = false;
            main.maxParticles = 1100;
            main.startLifetime = 99999f;
            main.startSpeed = 0f;
            main.simulationSpace = ParticleSystemSimulationSpace.World;
            main.startSize = 0.04f;

            var emission = ps.emission;
            emission.enabled = false;

            var renderer = go.GetComponent<ParticleSystemRenderer>();
            renderer.renderMode = ParticleSystemRenderMode.Billboard;
            Shader s = Shader.Find("Particles/Standard Unlit");
            if (s == null) s = Shader.Find("Legacy Shaders/Particles/Additive");
            if (s == null) s = Shader.Find("Unlit/Color");
            var mat = new Material(s);
            if (mat.HasProperty("_Color")) mat.SetColor("_Color", Color.white);
            renderer.material = mat;

            var particles = new ParticleSystem.Particle[900];
            var rng = new System.Random(44081);
            for (int i = 0; i < particles.Length; i++)
            {
                float x = Mathf.Lerp(-16f, 16f, (float)rng.NextDouble());
                float y = Mathf.Lerp(-22f, 22f, (float)rng.NextDouble());
                float z = Mathf.Lerp(8f, 80f, (float)rng.NextDouble());
                particles[i].position = new Vector3(x, y, z);
                particles[i].startLifetime = 99999f;
                particles[i].remainingLifetime = 99999f;
                particles[i].startSize = Mathf.Lerp(0.018f, 0.085f, (float)Math.Pow(rng.NextDouble(), 4));
                float tint = (float)rng.NextDouble();
                particles[i].startColor = tint > 0.82f
                    ? new Color(0.55f, 0.72f, 1f, 0.8f)
                    : new Color(1f, 0.95f, 0.82f, Mathf.Lerp(0.35f, 0.9f, (float)rng.NextDouble()));
            }
            ps.SetParticles(particles, particles.Length);
        }

        void BuildNebula(Vector3 center, Color color, int count, float radius)
        {
            var go = new GameObject("Procedural Nebula");
            go.transform.SetParent(transform);
            var ps = go.AddComponent<ParticleSystem>();
            var main = ps.main;
            main.loop = false;
            main.playOnAwake = false;
            main.maxParticles = count;
            main.startLifetime = 99999f;
            main.startSpeed = 0f;
            main.simulationSpace = ParticleSystemSimulationSpace.World;

            var emission = ps.emission;
            emission.enabled = false;

            var renderer = go.GetComponent<ParticleSystemRenderer>();
            Shader shader = Shader.Find("Particles/Standard Unlit");
            if (shader == null) shader = Shader.Find("Legacy Shaders/Particles/Alpha Blended");
            if (shader == null) shader = Shader.Find("Unlit/Transparent");
            var mat = new Material(shader);
            var soft = MakeSoftDiscTexture(96);
            if (mat.HasProperty("_MainTex")) mat.SetTexture("_MainTex", soft);
            if (mat.HasProperty("_BaseMap")) mat.SetTexture("_BaseMap", soft);
            renderer.material = mat;

            var particles = new ParticleSystem.Particle[count];
            var rng = new System.Random(count * 791 + Mathf.RoundToInt(center.x * 100f));
            for (int i = 0; i < count; i++)
            {
                Vector3 p = center + new Vector3(
                    Mathf.Lerp(-radius, radius, (float)rng.NextDouble()),
                    Mathf.Lerp(-radius * 0.62f, radius * 0.62f, (float)rng.NextDouble()),
                    Mathf.Lerp(-1.3f, 1.3f, (float)rng.NextDouble()));
                particles[i].position = p;
                particles[i].startLifetime = 99999f;
                particles[i].remainingLifetime = 99999f;
                particles[i].startSize = Mathf.Lerp(1.2f, 4.5f, (float)rng.NextDouble());
                Color c = color;
                c.a *= Mathf.Lerp(0.25f, 1f, (float)rng.NextDouble());
                particles[i].startColor = c;
            }
            ps.SetParticles(particles, count);
        }

        void BuildStar()
        {
            var go = GameObject.CreatePrimitive(PrimitiveType.Sphere);
            go.name = "Estrela Mae";
            go.transform.SetParent(transform);
            go.transform.position = new Vector3(2.55f, 5.6f, 2.2f);
            go.transform.localScale = Vector3.one * 2.15f;
            Destroy(go.GetComponent<Collider>());
            star = go.transform;

            Shader s = Shader.Find("NoveCeus/Star");
            starMat = new Material(s != null ? s : Shader.Find("Unlit/Color"));
            starMat.SetColor("_ColorA", new Color(1f, 0.92f, 0.56f));
            starMat.SetColor("_ColorB", new Color(1f, 0.32f, 0.04f));
            go.GetComponent<Renderer>().material = starMat;

            var light = go.AddComponent<Light>();
            light.type = LightType.Point;
            light.range = 28f;
            light.intensity = 3.6f;
            light.color = new Color(1f, 0.72f, 0.42f);

            for (int i = 0; i < 3; i++)
            {
                var halo = GameObject.CreatePrimitive(PrimitiveType.Sphere);
                halo.name = "Stellar Halo";
                halo.transform.SetParent(go.transform, false);
                halo.transform.localScale = Vector3.one * (1.18f + i * 0.24f);
                Destroy(halo.GetComponent<Collider>());
                var r = halo.GetComponent<Renderer>();
                Shader hs = Shader.Find("NoveCeus/Atmosphere");
                var hm = new Material(hs != null ? hs : Shader.Find("Unlit/Transparent"));
                if (hm.HasProperty("_Color")) hm.SetColor("_Color", new Color(1f, 0.52f + i * 0.08f, 0.12f, 0.35f));
                if (hm.HasProperty("_Intensity")) hm.SetFloat("_Intensity", 1.4f - i * 0.2f);
                r.material = hm;
            }
        }

        void BuildPlanet()
        {
            planetRoot = new GameObject("Aurora Prime Root").transform;
            planetRoot.SetParent(transform);
            planetRoot.position = new Vector3(0f, -0.75f, 0f);
            planetRoot.rotation = Quaternion.Euler(12f, -20f, 0f);

            var surface = GameObject.CreatePrimitive(PrimitiveType.Sphere);
            surface.name = "Procedural Planet Surface";
            surface.transform.SetParent(planetRoot, false);
            surface.transform.localScale = Vector3.one * 6.15f;
            Destroy(surface.GetComponent<Collider>());
            planetSurface = surface.transform;

            Shader surfaceShader = Shader.Find("NoveCeus/ProceduralPlanet");
            planetMat = new Material(surfaceShader != null ? surfaceShader : Shader.Find("Standard"));
            surface.GetComponent<Renderer>().material = planetMat;

            var clouds = GameObject.CreatePrimitive(PrimitiveType.Sphere);
            clouds.name = "Live Cloud Layer";
            clouds.transform.SetParent(planetRoot, false);
            clouds.transform.localScale = Vector3.one * 6.21f;
            Destroy(clouds.GetComponent<Collider>());
            cloudSphere = clouds.transform;
            Shader cloudShader = Shader.Find("NoveCeus/Clouds");
            cloudMat = new Material(cloudShader != null ? cloudShader : Shader.Find("Unlit/Transparent"));
            clouds.GetComponent<Renderer>().material = cloudMat;

            var atmosphere = GameObject.CreatePrimitive(PrimitiveType.Sphere);
            atmosphere.name = "Atmosphere Rim";
            atmosphere.transform.SetParent(planetRoot, false);
            atmosphere.transform.localScale = Vector3.one * 6.52f;
            Destroy(atmosphere.GetComponent<Collider>());
            Shader atmShader = Shader.Find("NoveCeus/Atmosphere");
            atmosphereMat = new Material(atmShader != null ? atmShader : Shader.Find("Unlit/Transparent"));
            atmosphere.GetComponent<Renderer>().material = atmosphereMat;

            BuildOrbitRing(planetRoot, 3.95f, new Color(0.28f, 0.76f, 1f, 0.26f), 0.012f, new Vector3(73f, 0f, 18f));
            BuildOrbitRing(planetRoot, 4.42f, new Color(0.85f, 0.68f, 0.32f, 0.16f), 0.009f, new Vector3(81f, 24f, 0f));
        }

        void BuildMoon()
        {
            var go = GameObject.CreatePrimitive(PrimitiveType.Sphere);
            go.name = "Lua Aegis";
            go.transform.SetParent(planetRoot, false);
            go.transform.localPosition = new Vector3(3.75f, 0.65f, -0.6f);
            go.transform.localScale = Vector3.one * 1.04f;
            Destroy(go.GetComponent<Collider>());
            moon = go.transform;

            Shader s = Shader.Find("NoveCeus/ProceduralPlanet");
            var m = new Material(s != null ? s : Shader.Find("Standard"));
            if (m.HasProperty("_OceanDeep")) m.SetColor("_OceanDeep", new Color(0.10f,0.11f,0.13f));
            if (m.HasProperty("_OceanShallow")) m.SetColor("_OceanShallow", new Color(0.18f,0.19f,0.21f));
            if (m.HasProperty("_LandLow")) m.SetColor("_LandLow", new Color(0.22f,0.23f,0.25f));
            if (m.HasProperty("_LandHigh")) m.SetColor("_LandHigh", new Color(0.42f,0.43f,0.46f));
            if (m.HasProperty("_Rock")) m.SetColor("_Rock", new Color(0.31f,0.32f,0.35f));
            if (m.HasProperty("_Water")) m.SetFloat("_Water", 0f);
            if (m.HasProperty("_Temperature")) m.SetFloat("_Temperature", -42f);
            if (m.HasProperty("_Life")) m.SetFloat("_Life", 0f);
            if (m.HasProperty("_Seed")) m.SetFloat("_Seed", 351f);
            go.GetComponent<Renderer>().material = m;
        }

        void BuildAsteroidBelt()
        {
            var belt = new GameObject("Live Asteroid Belt").transform;
            belt.SetParent(transform);
            belt.position = new Vector3(0f, 3.35f, 4.5f);
            belt.rotation = Quaternion.Euler(77f, 0f, 8f);

            var rng = new System.Random(1209);
            for (int i = 0; i < 92; i++)
            {
                float a = (float)rng.NextDouble() * Mathf.PI * 2f;
                float radius = Mathf.Lerp(3.7f, 6.5f, (float)rng.NextDouble());
                var rock = GameObject.CreatePrimitive(PrimitiveType.Sphere);
                rock.name = "Asteroid";
                rock.transform.SetParent(belt, false);
                rock.transform.localPosition = new Vector3(Mathf.Cos(a) * radius, 0f, Mathf.Sin(a) * radius * 0.28f);
                float size = Mathf.Lerp(0.035f, 0.17f, Mathf.Pow((float)rng.NextDouble(), 2.4f));
                rock.transform.localScale = new Vector3(size * 1.5f, size, size * 0.9f);
                rock.transform.localRotation = UnityEngine.Random.rotation;
                Destroy(rock.GetComponent<Collider>());
                var mat = new Material(Shader.Find("Standard"));
                float g = Mathf.Lerp(0.08f, 0.22f, (float)rng.NextDouble());
                mat.color = new Color(g, g * 0.92f, g * 0.82f);
                mat.SetFloat("_Glossiness", 0.08f);
                rock.GetComponent<Renderer>().material = mat;
            }
        }

        void BuildOrbitalStation(Vector3 position, float radius)
        {
            var root = new GameObject("Orbital Research Structure").transform;
            root.SetParent(transform);
            root.position = position;
            root.rotation = Quaternion.Euler(68f, 18f, 15f);

            BuildOrbitRing(root, radius, new Color(0.78f, 0.67f, 0.46f, 0.85f), 0.035f, Vector3.zero);
            BuildOrbitRing(root, radius * 0.68f, new Color(0.28f, 0.75f, 1f, 0.6f), 0.018f, new Vector3(0f, 32f, 0f));

            for (int i = 0; i < 6; i++)
            {
                float a = i / 6f * Mathf.PI * 2f;
                var node = GameObject.CreatePrimitive(PrimitiveType.Cube);
                node.name = "Station Module";
                node.transform.SetParent(root, false);
                node.transform.localPosition = new Vector3(Mathf.Cos(a) * radius, 0f, Mathf.Sin(a) * radius);
                node.transform.localScale = new Vector3(0.18f, 0.09f, 0.28f);
                Destroy(node.GetComponent<Collider>());
                var mat = new Material(Shader.Find("Standard"));
                mat.color = new Color(0.22f, 0.25f, 0.27f);
                mat.SetFloat("_Metallic", 0.82f);
                mat.SetFloat("_Glossiness", 0.78f);
                node.GetComponent<Renderer>().material = mat;
            }
        }

        void BuildDistantPlanet(Vector3 position, float radius, Color color)
        {
            var p = GameObject.CreatePrimitive(PrimitiveType.Sphere);
            p.name = "Distant World";
            p.transform.SetParent(transform);
            p.transform.position = position;
            p.transform.localScale = Vector3.one * radius * 2f;
            Destroy(p.GetComponent<Collider>());
            var mat = new Material(Shader.Find("Standard"));
            mat.color = color;
            mat.SetFloat("_Glossiness", 0.15f);
            p.GetComponent<Renderer>().material = mat;
        }

        void BuildOrbitRing(Transform parent, float radius, Color color, float width, Vector3 rotation)
        {
            var go = new GameObject("Orbit Ring");
            go.transform.SetParent(parent, false);
            go.transform.localRotation = Quaternion.Euler(rotation);
            var lr = go.AddComponent<LineRenderer>();
            lr.useWorldSpace = false;
            lr.loop = true;
            lr.positionCount = 128;
            lr.widthMultiplier = width;
            lr.startColor = color;
            lr.endColor = color;
            Shader shader = Shader.Find("Sprites/Default");
            lr.material = new Material(shader);
            for (int i = 0; i < 128; i++)
            {
                float a = i / 128f * Mathf.PI * 2f;
                lr.SetPosition(i, new Vector3(Mathf.Cos(a) * radius, 0f, Mathf.Sin(a) * radius));
            }
        }

        void BuildUI()
        {
            var eventGo = new GameObject("EventSystem");
            eventGo.transform.SetParent(transform);
            eventGo.AddComponent<EventSystem>();
            eventGo.AddComponent<StandaloneInputModule>();

            var canvasGo = new GameObject("Nove Ceus UI");
            canvasGo.transform.SetParent(transform);
            canvas = canvasGo.AddComponent<Canvas>();
            canvas.renderMode = RenderMode.ScreenSpaceOverlay;
            canvas.sortingOrder = 10;
            var scaler = canvasGo.AddComponent<CanvasScaler>();
            scaler.uiScaleMode = CanvasScaler.ScaleMode.ScaleWithScreenSize;
            scaler.referenceResolution = new Vector2(1080f, 1920f);
            scaler.matchWidthOrHeight = 0.5f;
            canvasGo.AddComponent<GraphicRaycaster>();

            BuildHeader();
            BuildPlanetPanel();
            BuildEraPanel();
            BuildQuickActions();
            BuildLowerInfo();
            BuildStatus();
            BuildBottomNavigation();
            BuildSceneLabels();
        }

        void BuildHeader()
        {
            Text title = MakeText(canvas.transform, "NOVE CÉUS", 66, paleGold, TextAnchor.MiddleLeft, FontStyle.Bold);
            SetRect(title.rectTransform, new Vector2(0f, 1f), new Vector2(0f, 1f), new Vector2(32f, -22f), new Vector2(450f, 78f));
            AddShadow(title.gameObject, new Color(0f,0f,0f,0.85f), new Vector2(3,-3));

            Text sub = MakeText(canvas.transform, "CRIAR  ·  EVOLUIR  ·  OBSERVAR", 20, textMuted, TextAnchor.MiddleLeft, FontStyle.Normal);
            SetRect(sub.rectTransform, new Vector2(0f, 1f), new Vector2(0f, 1f), new Vector2(42f, -92f), new Vector2(430f, 34f));

            MakeResourcePill(new Vector2(-455f, -26f), "✦", "12.4K", "+320/min");
            MakeResourcePill(new Vector2(-292f, -26f), "●", "3.6M", "+12.1K/min");
            MakeResourcePill(new Vector2(-129f, -26f), "◆", "87", "PESQ.");

            var gear = MakeButton(canvas.transform, "⚙", 30, () => ShowMessage("Configurações visuais mantêm 60 FPS quando possível."));
            SetRect(gear.GetComponent<RectTransform>(), new Vector2(1f,1f), new Vector2(1f,1f), new Vector2(-22f,-28f), new Vector2(64f,64f));
        }

        void MakeResourcePill(Vector2 anchored, string icon, string value, string rate)
        {
            var p = MakePanel(canvas.transform, new Vector2(150f, 66f), panelSoft, gold);
            SetRect(p.GetComponent<RectTransform>(), new Vector2(1f,1f), new Vector2(1f,1f), anchored, new Vector2(150f,66f));
            Text i = MakeText(p.transform, icon, 25, cyan, TextAnchor.MiddleCenter, FontStyle.Bold);
            SetRect(i.rectTransform, new Vector2(0f,.5f), new Vector2(0f,.5f), new Vector2(14f,0f), new Vector2(38f,54f));
            Text v = MakeText(p.transform, value, 24, textMain, TextAnchor.UpperLeft, FontStyle.Bold);
            SetRect(v.rectTransform, new Vector2(0f,.5f), new Vector2(0f,.5f), new Vector2(54f,4f), new Vector2(88f,31f));
            Text r = MakeText(p.transform, rate, 14, textMuted, TextAnchor.LowerLeft, FontStyle.Normal);
            SetRect(r.rectTransform, new Vector2(0f,.5f), new Vector2(0f,.5f), new Vector2(54f,-7f), new Vector2(90f,25f));
        }

        void BuildPlanetPanel()
        {
            var p = MakePanel(canvas.transform, new Vector2(335f, 585f), panel, gold);
            SetRect(p.GetComponent<RectTransform>(), new Vector2(0f,1f), new Vector2(0f,1f), new Vector2(20f,-142f), new Vector2(335f,585f));

            var portrait = MakeCircleImage(p.transform, new Color(0.04f,0.16f,0.24f,1f), gold);
            SetRect(portrait.rectTransform, new Vector2(0f,1f), new Vector2(0f,1f), new Vector2(22f,-18f), new Vector2(92f,92f));
            Text orb = MakeText(portrait.transform, "◎", 52, cyan, TextAnchor.MiddleCenter, FontStyle.Normal);
            Stretch(orb.rectTransform, 0f);

            worldNameText = MakeText(p.transform, "Aurora Prime", 32, paleGold, TextAnchor.MiddleLeft, FontStyle.Bold);
            SetRect(worldNameText.rectTransform, new Vector2(0f,1f), new Vector2(0f,1f), new Vector2(125f,-21f), new Vector2(190f,42f));
            Text classText = MakeText(p.transform, "CLASSE M · MUNDO EM EVOLUÇÃO", 16, textMuted, TextAnchor.MiddleLeft, FontStyle.Normal);
            SetRect(classText.rectTransform, new Vector2(0f,1f), new Vector2(0f,1f), new Vector2(125f,-65f), new Vector2(195f,28f));

            float y = -128f;
            massText = MakeStatRow(p.transform, "MASSA", ref y);
            atmosphereText = MakeStatRow(p.transform, "ATMOSFERA", ref y);
            temperatureText = MakeStatRow(p.transform, "TEMPERATURA", ref y);
            waterText = MakeStatRow(p.transform, "ÁGUA", ref y);
            biodiversityText = MakeStatRow(p.transform, "BIODIVERSIDADE", ref y);
            civilizationText = MakeStatRow(p.transform, "CIVILIZAÇÃO", ref y);
            habitabilityText = MakeStatRow(p.transform, "HABITABILIDADE", ref y);

            var detail = MakeButton(p.transform, "VER DETALHES  ›", 19, () => ShowMessage("Dados planetários atualizados em tempo real."));
            SetRect(detail.GetComponent<RectTransform>(), new Vector2(.5f,0f), new Vector2(.5f,0f), new Vector2(0f,22f), new Vector2(280f,52f));
        }

        Text MakeStatRow(Transform parent, string label, ref float y)
        {
            Text l = MakeText(parent, label, 16, textMuted, TextAnchor.MiddleLeft, FontStyle.Bold);
            SetRect(l.rectTransform, new Vector2(0f,1f), new Vector2(0f,1f), new Vector2(24f,y), new Vector2(145f,40f));
            Text v = MakeText(parent, "—", 18, textMain, TextAnchor.MiddleRight, FontStyle.Bold);
            SetRect(v.rectTransform, new Vector2(1f,1f), new Vector2(1f,1f), new Vector2(-20f,y), new Vector2(150f,40f));
            y -= 55f;
            return v;
        }

        void BuildEraPanel()
        {
            var p = MakePanel(canvas.transform, new Vector2(330f, 710f), panel, gold);
            SetRect(p.GetComponent<RectTransform>(), new Vector2(1f,1f), new Vector2(1f,1f), new Vector2(-20f,-142f), new Vector2(330f,710f));

            Text h = MakeText(p.transform, "JORNADA DE UM MUNDO", 24, paleGold, TextAnchor.MiddleCenter, FontStyle.Bold);
            SetRect(h.rectTransform, new Vector2(.5f,1f), new Vector2(.5f,1f), new Vector2(0f,-22f), new Vector2(290f,44f));
            MakeLine(p.transform, new Vector2(0.5f,1f), new Vector2(0f,-68f), new Vector2(270f,2f), gold);

            string[] sub =
            {
                "A matéria se reúne", "Gravidade desperta", "Fogo e transformação",
                "A vida encontra espaço", "O início da complexidade", "Mundos verdes",
                "A diversidade cresce", "Mentes observam o céu", "Além das fronteiras"
            };

            for (int i = 0; i < sim.EraNames.Length; i++)
            {
                float y = -92f - i * 65f;
                var dot = MakeCircleImage(p.transform, new Color(0.05f,0.1f,0.14f,1f), gold);
                SetRect(dot.rectTransform, new Vector2(0f,1f), new Vector2(0f,1f), new Vector2(18f,y), new Vector2(43f,43f));
                Text n = MakeText(dot.transform, (i + 1).ToString(), 17, textMain, TextAnchor.MiddleCenter, FontStyle.Bold);
                Stretch(n.rectTransform, 0f);
                eraDots.Add(dot);

                Text row = MakeText(p.transform, sim.EraNames[i] + "\n<size=14>" + sub[i] + "</size>", 19, textMain, TextAnchor.UpperLeft, FontStyle.Normal);
                row.supportRichText = true;
                SetRect(row.rectTransform, new Vector2(0f,1f), new Vector2(0f,1f), new Vector2(75f,y + 3f), new Vector2(230f,55f));
                eraRows.Add(row);

                if (i < sim.EraNames.Length - 1)
                    MakeLine(p.transform, new Vector2(0f,1f), new Vector2(39f,y - 44f), new Vector2(2f,27f), new Color(gold.r,gold.g,gold.b,0.5f));
            }
        }

        void BuildQuickActions()
        {
            var p = MakePanel(canvas.transform, new Vector2(290f, 430f), panel, gold);
            SetRect(p.GetComponent<RectTransform>(), new Vector2(0f,1f), new Vector2(0f,1f), new Vector2(22f,-760f), new Vector2(290f,430f));

            Text h = MakeText(p.transform, "✦  AÇÕES RÁPIDAS", 23, paleGold, TextAnchor.MiddleLeft, FontStyle.Bold);
            SetRect(h.rectTransform, new Vector2(0f,1f), new Vector2(0f,1f), new Vector2(18f,-14f), new Vector2(250f,42f));

            AddActionButton(p.transform, 0, "ÓRBITA", "Estabilizar distância", sim.AdjustOrbit);
            AddActionButton(p.transform, 1, "CLIMA", "Temperatura e atmosfera", sim.ModifyClimate);
            AddActionButton(p.transform, 2, "VIDA", "Semear biosfera", sim.IntroduceLife);
            AddActionButton(p.transform, 3, "TERRAFORMAR", "Remodelar o mundo", sim.Terraform);
            AddActionButton(p.transform, 4, "TEMPO", "Acelerar eras", sim.CycleTimeScale);
        }

        void AddActionButton(Transform parent, int index, string title, string subtitle, Action action)
        {
            var b = MakeButton(parent, "", 17, action);
            SetRect(b.GetComponent<RectTransform>(), new Vector2(.5f,1f), new Vector2(.5f,1f), new Vector2(0f,-66f-index*70f), new Vector2(252f,58f));

            var icon = MakeCircleImage(b.transform, new Color(0.03f,0.15f,0.20f,1f), cyan);
            SetRect(icon.rectTransform, new Vector2(0f,.5f), new Vector2(0f,.5f), new Vector2(8f,0f), new Vector2(42f,42f));
            Text mark = MakeText(icon.transform, (index + 1).ToString(), 18, cyan, TextAnchor.MiddleCenter, FontStyle.Bold);
            Stretch(mark.rectTransform,0f);

            Text t = MakeText(b.transform, title, 16, textMain, TextAnchor.UpperLeft, FontStyle.Bold);
            SetRect(t.rectTransform, new Vector2(0f,.5f), new Vector2(0f,.5f), new Vector2(61f,8f), new Vector2(175f,24f));
            Text st = MakeText(b.transform, subtitle, 12, textMuted, TextAnchor.LowerLeft, FontStyle.Normal);
            SetRect(st.rectTransform, new Vector2(0f,.5f), new Vector2(0f,.5f), new Vector2(61f,-9f), new Vector2(175f,22f));
        }

        void BuildLowerInfo()
        {
            var moonPanel = MakePanel(canvas.transform, new Vector2(275f, 128f), panel, gold);
            SetRect(moonPanel.GetComponent<RectTransform>(), new Vector2(1f,1f), new Vector2(1f,1f), new Vector2(-26f,-890f), new Vector2(275f,128f));
            Text mh = MakeText(moonPanel.transform, "LUA AEGIS", 21, paleGold, TextAnchor.UpperLeft, FontStyle.Bold);
            SetRect(mh.rectTransform, new Vector2(0f,1f),new Vector2(0f,1f),new Vector2(18f,-14f),new Vector2(235f,28f));
            moonText = MakeText(moonPanel.transform, "Influência orbital estável", 15, textMain, TextAnchor.UpperLeft, FontStyle.Normal);
            SetRect(moonText.rectTransform, new Vector2(0f,1f),new Vector2(0f,1f),new Vector2(18f,-49f),new Vector2(235f,64f));

            var resPanel = MakePanel(canvas.transform, new Vector2(275f, 175f), panel, gold);
            SetRect(resPanel.GetComponent<RectTransform>(), new Vector2(1f,1f), new Vector2(1f,1f), new Vector2(-26f,-1033f), new Vector2(275f,175f));
            Text rh = MakeText(resPanel.transform, "RECURSOS NA ÓRBITA", 19, paleGold, TextAnchor.UpperLeft, FontStyle.Bold);
            SetRect(rh.rectTransform,new Vector2(0f,1f),new Vector2(0f,1f),new Vector2(18f,-14f),new Vector2(240f,28f));
            resourceText = MakeText(resPanel.transform, "Ferro      +12/min\nSilício      +8/min\nÁgua gelada  +6/min", 15, textMain, TextAnchor.UpperLeft, FontStyle.Normal);
            resourceText.lineSpacing = 1.25f;
            SetRect(resourceText.rectTransform,new Vector2(0f,1f),new Vector2(0f,1f),new Vector2(22f,-54f),new Vector2(230f,105f));
        }

        void BuildStatus()
        {
            var p = MakePanel(canvas.transform, new Vector2(680f, 154f), new Color(0.025f,0.075f,0.11f,0.96f), gold);
            SetRect(p.GetComponent<RectTransform>(), new Vector2(.5f,0f), new Vector2(.5f,0f), new Vector2(0f,460f), new Vector2(680f,154f));

            var vortex = MakeCircleImage(p.transform, new Color(0.02f,0.12f,0.18f,1f), cyan);
            SetRect(vortex.rectTransform,new Vector2(0f,.5f),new Vector2(0f,.5f),new Vector2(24f,0f),new Vector2(104f,104f));
            Text swirl = MakeText(vortex.transform, "↻", 56, cyan, TextAnchor.MiddleCenter, FontStyle.Bold);
            Stretch(swirl.rectTransform,0f);

            statusText = MakeText(p.transform, "SIMULANDO…\nERA DOS OCEANOS", 24, textMain, TextAnchor.UpperLeft, FontStyle.Bold);
            SetRect(statusText.rectTransform,new Vector2(0f,.5f),new Vector2(0f,.5f),new Vector2(150f,27f),new Vector2(470f,62f));

            var barBg = MakeImage(p.transform,new Color(0.04f,0.11f,0.15f,1f));
            SetRect(barBg.rectTransform,new Vector2(0f,.5f),new Vector2(0f,.5f),new Vector2(150f,-28f),new Vector2(455f,16f));
            progressFill = MakeImage(barBg.transform,cyan);
            progressFill.type = Image.Type.Filled;
            progressFill.fillMethod = Image.FillMethod.Horizontal;
            progressFill.fillOrigin = 0;
            Stretch(progressFill.rectTransform,2f);

            eventText = MakeText(p.transform, "Um mundo desperta.", 14, textMuted, TextAnchor.LowerLeft, FontStyle.Italic);
            SetRect(eventText.rectTransform,new Vector2(0f,0f),new Vector2(0f,0f),new Vector2(150f,10f),new Vector2(490f,28f));
        }

        void BuildBottomNavigation()
        {
            var navRoot = new GameObject("Primary Navigation");
            navRoot.transform.SetParent(canvas.transform);
            var rr = navRoot.AddComponent<RectTransform>();
            SetRect(rr,new Vector2(.5f,0f),new Vector2(.5f,0f),new Vector2(0f,250f),new Vector2(1020f,190f));

            string[] labels = { "CRIAR", "EVOLUIR", "ÓRBITA", "PESQUISA", "MAPA ESTELAR" };
            Action[] acts = { sim.CreateNewWorld, sim.Evolve, sim.AdjustOrbit, sim.Research, ToggleMapView };
            Color[] accents = { cyan, teal, paleGold, new Color(.66f,.44f,1f), cyan };

            for(int i=0;i<labels.Length;i++)
            {
                float x = -400f + i*200f;
                var outer = MakeCircleImage(navRoot.transform,new Color(0.02f,0.08f,0.12f,.97f),gold);
                SetRect(outer.rectTransform,new Vector2(.5f,.5f),new Vector2(.5f,.5f),new Vector2(x,22f),new Vector2(126f,126f));
                var b = MakeButton(outer.transform,"",16,acts[i]);
                Stretch(b.GetComponent<RectTransform>(),10f);
                b.GetComponent<Image>().color = new Color(0.02f,0.09f,0.13f,0.92f);
                Text sig = MakeText(b.transform,(i+1).ToString("00"),34,accents[i],TextAnchor.MiddleCenter,FontStyle.Bold);
                Stretch(sig.rectTransform,0f);

                Text lbl = MakeText(navRoot.transform,labels[i],18,textMain,TextAnchor.MiddleCenter,FontStyle.Bold);
                SetRect(lbl.rectTransform,new Vector2(.5f,.5f),new Vector2(.5f,.5f),new Vector2(x,-60f),new Vector2(170f,36f));
            }

            var secondary = MakePanel(canvas.transform,new Vector2(1020f,122f),new Color(0.018f,0.06f,0.085f,.82f),new Color(gold.r,gold.g,gold.b,.45f));
            SetRect(secondary.GetComponent<RectTransform>(),new Vector2(.5f,0f),new Vector2(.5f,0f),new Vector2(0f,48f),new Vector2(1020f,122f));

            string[] mini = { "EVENTOS","ESPÉCIES","CLIMA","RECURSOS","MISSÕES","ARQUIVO","CONQUISTAS","MAIS" };
            for(int i=0;i<mini.Length;i++)
            {
                Text t = MakeText(secondary.transform,mini[i],13,i==1?cyan:textMuted,TextAnchor.MiddleCenter,i==1?FontStyle.Bold:FontStyle.Normal);
                SetRect(t.rectTransform,new Vector2(0f,.5f),new Vector2(0f,.5f),new Vector2(15f+i*124f,0f),new Vector2(118f,76f));
            }
        }

        void BuildSceneLabels()
        {
            Text starLabel = MakeText(canvas.transform,"ESTRELA MÃE\n<size=14>Núcleo Luminaris</size>",19,paleGold,TextAnchor.MiddleCenter,FontStyle.Bold);
            starLabel.supportRichText = true;
            SetRect(starLabel.rectTransform,new Vector2(.5f,1f),new Vector2(.5f,1f),new Vector2(168f,-157f),new Vector2(230f,64f));
            AddShadow(starLabel.gameObject,Color.black,new Vector2(2,-2));

            Text belt = MakeText(canvas.transform,"NÉVOA DE ASTEROIDES\n<size=13>Recursos raros</size>",17,textMain,TextAnchor.MiddleCenter,FontStyle.Bold);
            belt.supportRichText = true;
            SetRect(belt.rectTransform,new Vector2(.5f,1f),new Vector2(.5f,1f),new Vector2(-30f,-345f),new Vector2(230f,58f));

            ageText = MakeText(canvas.transform,"Aurora Prime",26,paleGold,TextAnchor.MiddleCenter,FontStyle.Bold);
            SetRect(ageText.rectTransform,new Vector2(.5f,.5f),new Vector2(.5f,.5f),new Vector2(0f,-405f),new Vector2(340f,42f));

            speedText = MakeText(canvas.transform,"TEMPO 1x",16,cyan,TextAnchor.MiddleCenter,FontStyle.Bold);
            SetRect(speedText.rectTransform,new Vector2(.5f,.5f),new Vector2(.5f,.5f),new Vector2(0f,-450f),new Vector2(220f,30f));

            mapModeText = MakeText(canvas.transform,"",15,textMuted,TextAnchor.MiddleCenter,FontStyle.Italic);
            SetRect(mapModeText.rectTransform,new Vector2(.5f,.5f),new Vector2(.5f,.5f),new Vector2(0f,-485f),new Vector2(360f,30f));
        }

        void Update()
        {
            if (planetRoot == null || sim == null) return;

            planetRoot.Rotate(Vector3.up, 1.15f * Time.deltaTime, Space.Self);
            if (cloudSphere != null) cloudSphere.Rotate(Vector3.up, 2.1f * Time.deltaTime, Space.Self);
            if (moon != null) moon.Rotate(Vector3.up, 4f * Time.deltaTime, Space.Self);
            if (star != null) star.Rotate(new Vector3(0.08f,0.18f,0f), 8f * Time.deltaTime, Space.Self);

            HandlePlanetInput();

            if (cam != null)
            {
                Vector3 target = new Vector3(0f, mapView ? 0.7f : 0.05f, cameraTargetZ);
                cam.transform.position = Vector3.Lerp(cam.transform.position,target,1f-Mathf.Exp(-4f*Time.deltaTime));
                cam.transform.LookAt(mapView ? new Vector3(0f,1.3f,2.2f) : Vector3.zero);
            }

            ApplySimulationToVisuals();

            refreshTimer -= Time.deltaTime;
            if (refreshTimer <= 0f)
            {
                refreshTimer = 0.16f;
                RefreshAll();
            }
        }

        void HandlePlanetInput()
        {
            if (Input.touchCount == 1)
            {
                Touch t = Input.GetTouch(0);
                if (EventSystem.current != null && EventSystem.current.IsPointerOverGameObject(t.fingerId)) return;
                if (t.phase == TouchPhase.Moved)
                    planetRoot.Rotate(Vector3.up, -t.deltaPosition.x * 0.12f, Space.World);
            }
            else if (Input.touchCount == 2)
            {
                Touch a = Input.GetTouch(0);
                Touch b = Input.GetTouch(1);
                float prev = (a.position-a.deltaPosition - (b.position-b.deltaPosition)).magnitude;
                float now = (a.position-b.position).magnitude;
                cameraTargetZ = Mathf.Clamp(cameraTargetZ - (now-prev)*0.012f,-18.5f,-10.8f);
            }
            else if (Input.GetMouseButtonDown(0))
            {
                lastPointer = Input.mousePosition;
            }
            else if (Input.GetMouseButton(0))
            {
                if (EventSystem.current != null && EventSystem.current.IsPointerOverGameObject()) return;
                Vector2 now = Input.mousePosition;
                planetRoot.Rotate(Vector3.up, -(now.x-lastPointer.x)*0.18f,Space.World);
                lastPointer = now;
            }

            float scroll = Input.mouseScrollDelta.y;
            if (Mathf.Abs(scroll) > 0.01f)
                cameraTargetZ = Mathf.Clamp(cameraTargetZ + scroll * 0.55f,-18.5f,-10.8f);
        }

        void ApplySimulationToVisuals()
        {
            var s = sim.State;
            Vector3 sunDir = star != null ? (star.position - planetRoot.position).normalized : new Vector3(.5f,.7f,-.2f);

            if (planetMat != null)
            {
                if (planetMat.HasProperty("_Water")) planetMat.SetFloat("_Water",s.water);
                if (planetMat.HasProperty("_Temperature")) planetMat.SetFloat("_Temperature",s.temperatureC);
                if (planetMat.HasProperty("_Life")) planetMat.SetFloat("_Life",s.biodiversity);
                if (planetMat.HasProperty("_Civilization")) planetMat.SetFloat("_Civilization",s.civilization);
                if (planetMat.HasProperty("_Seed")) planetMat.SetFloat("_Seed",s.seed);
                if (planetMat.HasProperty("_SunDir")) planetMat.SetVector("_SunDir",sunDir);
            }

            if (cloudMat != null)
            {
                if (cloudMat.HasProperty("_Coverage")) cloudMat.SetFloat("_Coverage",Mathf.Lerp(.68f,.35f,s.water));
                if (cloudMat.HasProperty("_Seed")) cloudMat.SetFloat("_Seed",s.seed+19);
            }

            if (atmosphereMat != null && atmosphereMat.HasProperty("_Intensity"))
                atmosphereMat.SetFloat("_Intensity",Mathf.Lerp(.45f,2.2f,s.atmosphere));

            if (starMat != null && starMat.HasProperty("_Pulse"))
                starMat.SetFloat("_Pulse",1f + Mathf.Sin(Time.time*1.7f)*.06f);
        }

        void RefreshAll()
        {
            var s = sim.State;
            if (worldNameText != null) worldNameText.text = s.worldName.ToUpperInvariant();
            if (massText != null) massText.text = s.massEarth.ToString("0.00") + " M⊕";
            if (atmosphereText != null) atmosphereText.text = Mathf.RoundToInt(s.atmosphere*100f) + "%";
            if (temperatureText != null)
            {
                temperatureText.text = s.temperatureC.ToString("0") + " °C";
                temperatureText.color = s.temperatureC > -12f && s.temperatureC < 44f ? new Color(.42f,1f,.58f) : new Color(1f,.47f,.28f);
            }
            if (waterText != null) waterText.text = Mathf.RoundToInt(s.water*100f) + "%";
            if (biodiversityText != null) biodiversityText.text = Mathf.RoundToInt(s.biodiversity*3200f).ToString("N0") + " espécies";
            if (civilizationText != null) civilizationText.text = CivilizationLabel(s.civilization);
            if (habitabilityText != null) habitabilityText.text = Mathf.RoundToInt(sim.Habitability()*100f) + "%";
            if (speedText != null) speedText.text = "TEMPO  " + sim.TimeScale.ToString("0") + "x";
            if (ageText != null) ageText.text = s.worldName + "  ·  " + FormatAge(s.ageYears);
            if (moonText != null) moonText.text = "Massa: 0,012 M⊕\nInfluência: " + (s.orbitAU > 1.35f ? "Fraca" : "Estável");
            if (resourceText != null) resourceText.text =
                "Ferro         +" + Mathf.RoundToInt(8f+s.minerals*14f) + "/min\n" +
                "Silício       +" + Mathf.RoundToInt(5f+s.minerals*9f) + "/min\n" +
                "Água gelada   +" + Mathf.RoundToInt(2f+s.water*8f) + "/min";

            if (statusText != null)
                statusText.text = "SIMULANDO…\n" + sim.CurrentEra.ToUpperInvariant() + "  ·  " + Mathf.RoundToInt(sim.EraProgress*100f) + "%";
            if (progressFill != null) progressFill.fillAmount = sim.EraProgress;
            if (eventText != null) eventText.text = "“" + sim.LastEvent + "”";
            if (mapModeText != null) mapModeText.text = mapView ? "VISÃO DO SISTEMA · toque em MAPA ESTELAR para retornar" : "Arraste o planeta · pinça/scroll para aproximar";

            for(int i=0;i<eraRows.Count;i++)
            {
                bool current = i==sim.EraIndex;
                bool past = i<sim.EraIndex;
                eraRows[i].color = current ? cyan : past ? paleGold : textMain;
                eraRows[i].fontStyle = current ? FontStyle.Bold : FontStyle.Normal;
                eraDots[i].color = current ? new Color(0.03f,0.28f,0.36f,1f) : new Color(0.04f,0.09f,0.13f,1f);
                var outline = eraDots[i].GetComponent<Outline>();
                if (outline != null) outline.effectColor = current ? cyan : gold;
            }
        }

        void ToggleMapView()
        {
            mapView = !mapView;
            cameraTargetZ = mapView ? -18.2f : -12.7f;
            ShowMessage(mapView ? "Mapa estelar: visão ampliada do sistema." : "Retornando à órbita de Aurora Prime.");
        }

        void ShowMessage(string message)
        {
            if (sim != null)
            {
                // Reaproveita o espaço de eventos sem transformar a tela em modal.
                if (eventText != null) eventText.text = "“" + message + "”";
            }
        }

        string CivilizationLabel(float v)
        {
            if (v < .08f) return "Primitiva";
            if (v < .25f) return "Tribal";
            if (v < .48f) return "Industrial";
            if (v < .72f) return "Planetária";
            if (v < .92f) return "Interplanetária";
            return "Estelar";
        }

        string FormatAge(double years)
        {
            if (years >= 1_000_000_000d) return (years/1_000_000_000d).ToString("0.00") + " bi anos";
            if (years >= 1_000_000d) return (years/1_000_000d).ToString("0") + " mi anos";
            return years.ToString("0") + " anos";
        }

        GameObject MakePanel(Transform parent, Vector2 size, Color fill, Color border)
        {
            var go = new GameObject("Cosmic Panel");
            go.transform.SetParent(parent,false);
            var rt = go.AddComponent<RectTransform>();
            rt.sizeDelta = size;
            var img = go.AddComponent<Image>();
            img.color = fill;
            var outline = go.AddComponent<Outline>();
            outline.effectColor = border;
            outline.effectDistance = new Vector2(2f,-2f);
            outline.useGraphicAlpha = true;

            MakeLine(go.transform,new Vector2(.5f,1f),new Vector2(0f,-4f),new Vector2(size.x-18f,2f),new Color(border.r,border.g,border.b,.55f));
            return go;
        }

        Button MakeButton(Transform parent, string label, int size, Action action)
        {
            var go = new GameObject("Button " + label);
            go.transform.SetParent(parent,false);
            var rt = go.AddComponent<RectTransform>();
            rt.sizeDelta = new Vector2(180f,54f);
            var img = go.AddComponent<Image>();
            img.color = new Color(0.035f,0.12f,0.16f,0.96f);
            var outline = go.AddComponent<Outline>();
            outline.effectColor = new Color(gold.r,gold.g,gold.b,.72f);
            outline.effectDistance = new Vector2(1.4f,-1.4f);
            var b = go.AddComponent<Button>();
            var colors = b.colors;
            colors.normalColor = Color.white;
            colors.highlightedColor = new Color(.78f,.94f,1f,1f);
            colors.pressedColor = new Color(.52f,.85f,1f,1f);
            colors.selectedColor = Color.white;
            b.colors = colors;
            b.targetGraphic = img;
            if (action != null) b.onClick.AddListener(() => action());

            if (!string.IsNullOrEmpty(label))
            {
                Text t = MakeText(go.transform,label,size,textMain,TextAnchor.MiddleCenter,FontStyle.Bold);
                Stretch(t.rectTransform,6f);
            }
            return b;
        }

        Image MakeImage(Transform parent, Color color)
        {
            var go = new GameObject("Image");
            go.transform.SetParent(parent,false);
            var rt = go.AddComponent<RectTransform>();
            var img = go.AddComponent<Image>();
            img.color = color;
            return img;
        }

        Image MakeCircleImage(Transform parent, Color fill, Color border)
        {
            var go = new GameObject("Orb");
            go.transform.SetParent(parent,false);
            var rt = go.AddComponent<RectTransform>();
            rt.sizeDelta = new Vector2(80f,80f);
            var img = go.AddComponent<Image>();
            img.sprite = GetCircleSprite();
            img.color = fill;
            var outline = go.AddComponent<Outline>();
            outline.effectColor = border;
            outline.effectDistance = new Vector2(2f,-2f);
            return img;
        }

        Text MakeText(Transform parent, string value, int size, Color color, TextAnchor anchor, FontStyle style)
        {
            var go = new GameObject("Text");
            go.transform.SetParent(parent,false);
            var rt = go.AddComponent<RectTransform>();
            var t = go.AddComponent<Text>();
            t.font = font;
            t.text = value;
            t.fontSize = size;
            t.color = color;
            t.alignment = anchor;
            t.fontStyle = style;
            t.horizontalOverflow = HorizontalWrapMode.Wrap;
            t.verticalOverflow = VerticalWrapMode.Overflow;
            t.raycastTarget = false;
            return t;
        }

        void MakeLine(Transform parent, Vector2 anchor, Vector2 pos, Vector2 size, Color color)
        {
            var img = MakeImage(parent,color);
            SetRect(img.rectTransform,anchor,anchor,pos,size);
        }

        void AddShadow(GameObject go, Color color, Vector2 distance)
        {
            var s = go.AddComponent<Shadow>();
            s.effectColor = color;
            s.effectDistance = distance;
        }

        Sprite circleSprite;
        Sprite GetCircleSprite()
        {
            if (circleSprite != null) return circleSprite;
            const int size = 128;
            var tex = new Texture2D(size,size,TextureFormat.RGBA32,false);
            tex.wrapMode = TextureWrapMode.Clamp;
            tex.filterMode = FilterMode.Bilinear;
            var pixels = new Color[size*size];
            Vector2 c = new Vector2((size-1)*.5f,(size-1)*.5f);
            float radius = size*.49f;
            for(int y=0;y<size;y++)
            for(int x=0;x<size;x++)
            {
                float d = Vector2.Distance(new Vector2(x,y),c)/radius;
                float a = Mathf.Clamp01((1f-d)*18f);
                pixels[y*size+x] = new Color(1f,1f,1f,a);
            }
            tex.SetPixels(pixels);
            tex.Apply();
            circleSprite = Sprite.Create(tex,new Rect(0,0,size,size),new Vector2(.5f,.5f),100f);
            return circleSprite;
        }

        Texture2D MakeSoftDiscTexture(int size)
        {
            var tex = new Texture2D(size,size,TextureFormat.RGBA32,false);
            tex.wrapMode = TextureWrapMode.Clamp;
            tex.filterMode = FilterMode.Bilinear;
            var pixels = new Color[size*size];
            Vector2 c = new Vector2((size-1)*.5f,(size-1)*.5f);
            float r = size*.5f;
            for(int y=0;y<size;y++)
            for(int x=0;x<size;x++)
            {
                float d = Mathf.Clamp01(Vector2.Distance(new Vector2(x,y),c)/r);
                float a = Mathf.Pow(1f-d,2.6f);
                pixels[y*size+x] = new Color(1f,1f,1f,a);
            }
            tex.SetPixels(pixels);
            tex.Apply();
            return tex;
        }

        void SetRect(RectTransform rt, Vector2 anchorMin, Vector2 anchorMax, Vector2 anchoredPosition, Vector2 size)
        {
            rt.anchorMin = anchorMin;
            rt.anchorMax = anchorMax;
            rt.pivot = new Vector2(
                Mathf.Approximately(anchorMin.x,1f) ? 1f : Mathf.Approximately(anchorMin.x,0f) ? 0f : .5f,
                Mathf.Approximately(anchorMin.y,1f) ? 1f : Mathf.Approximately(anchorMin.y,0f) ? 0f : .5f);
            rt.anchoredPosition = anchoredPosition;
            rt.sizeDelta = size;
        }

        void Stretch(RectTransform rt, float inset)
        {
            rt.anchorMin = Vector2.zero;
            rt.anchorMax = Vector2.one;
            rt.offsetMin = new Vector2(inset,inset);
            rt.offsetMax = new Vector2(-inset,-inset);
        }
    }
}

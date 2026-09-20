using System;
using UnityEngine;

namespace NoveCeus
{
    [Serializable]
    public sealed class WorldState
    {
        public string worldName = "Aurora Prime";
        public double ageYears = 720_000_000d;
        public float massEarth = 1.0f;
        public float atmosphere = 0.78f;
        public float temperatureC = 16f;
        public float water = 0.71f;
        public float biodiversity = 0.18f;
        public float civilization = 0.04f;
        public float orbitAU = 1.0f;
        public float research = 0.08f;
        public float minerals = 0.35f;
        public int seed = 9137;
    }

    public sealed class UniverseSimulation : MonoBehaviour
    {
        public static UniverseSimulation Instance { get; private set; }

        public WorldState State { get; private set; } = new WorldState();
        public float TimeScale { get; private set; } = 1f;
        public int EraIndex { get; private set; }
        public float EraProgress { get; private set; }
        public string LastEvent { get; private set; } = "Um mundo desperta entre as estrelas.";

        public event Action Changed;

        readonly string[] eraNames =
        {
            "Poeira Cósmica",
            "Protoplaneta",
            "Mundo Vulcânico",
            "Oceanos",
            "Vida Microbiana",
            "Florestas",
            "Fauna",
            "Civilização",
            "Era Espacial"
        };

        public string[] EraNames => eraNames;
        public string CurrentEra => eraNames[Mathf.Clamp(EraIndex, 0, eraNames.Length - 1)];

        void Awake()
        {
            if (Instance != null && Instance != this)
            {
                Destroy(gameObject);
                return;
            }
            Instance = this;
            DontDestroyOnLoad(gameObject);
            RecalculateEra();
        }

        void Update()
        {
            // Base: 240 mil anos/s no 1x. Escalas altas servem para observar eras.
            double deltaYears = 240000d * Time.deltaTime * TimeScale;
            State.ageYears += deltaYears;

            NaturalEvolution((float)Math.Min(deltaYears / 5_000_000d, 0.1d));
            RecalculateEra();
        }

        void NaturalEvolution(float step)
        {
            float habitable = Habitability();

            if (EraIndex >= 3)
            {
                State.atmosphere = Mathf.Clamp01(State.atmosphere + 0.0007f * step);
            }

            if (EraIndex >= 4 && habitable > 0.46f)
            {
                State.biodiversity = Mathf.Clamp01(State.biodiversity + (0.0014f + 0.003f * habitable) * step);
            }

            if (EraIndex >= 7 && State.biodiversity > 0.56f)
            {
                State.civilization = Mathf.Clamp01(State.civilization + 0.0018f * step * State.biodiversity);
                State.research = Mathf.Clamp01(State.research + 0.0014f * step * State.civilization);
            }

            if (UnityEngine.Random.value < 0.00035f * Time.deltaTime * Mathf.Sqrt(TimeScale))
            {
                TriggerNaturalEvent();
            }

            Changed?.Invoke();
        }

        void TriggerNaturalEvent()
        {
            int roll = UnityEngine.Random.Range(0, 4);
            switch (roll)
            {
                case 0:
                    State.minerals = Mathf.Clamp01(State.minerals + 0.025f);
                    LastEvent = "Chuva de meteoros trouxe minerais raros.";
                    break;
                case 1:
                    State.temperatureC += UnityEngine.Random.Range(-1.8f, 1.2f);
                    LastEvent = "Oscilação estelar alterou o clima global.";
                    break;
                case 2:
                    State.water = Mathf.Clamp01(State.water + UnityEngine.Random.Range(-0.015f, 0.025f));
                    LastEvent = "Cometas ricos em gelo cruzaram a órbita.";
                    break;
                default:
                    if (State.biodiversity > 0.08f)
                        State.biodiversity = Mathf.Clamp01(State.biodiversity - 0.018f);
                    LastEvent = "Atividade tectônica remodelou continentes.";
                    break;
            }
        }

        public float Habitability()
        {
            float tempScore = 1f - Mathf.Clamp01(Mathf.Abs(State.temperatureC - 18f) / 95f);
            float waterScore = 1f - Mathf.Abs(State.water - 0.58f);
            float atmScore = 1f - Mathf.Abs(State.atmosphere - 0.8f);
            float orbitScore = 1f - Mathf.Clamp01(Mathf.Abs(State.orbitAU - 1f) / 1.5f);
            return Mathf.Clamp01(tempScore * 0.32f + waterScore * 0.24f + atmScore * 0.22f + orbitScore * 0.22f);
        }

        public void AdjustOrbit()
        {
            float target = State.temperatureC > 30f ? 1.08f : State.temperatureC < 4f ? 0.94f : State.orbitAU + 0.03f;
            State.orbitAU = Mathf.Clamp(target, 0.62f, 1.75f);
            State.temperatureC += (1f - State.orbitAU) * 8f;
            LastEvent = "Órbita recalibrada para " + State.orbitAU.ToString("0.00") + " UA.";
            Notify();
        }

        public void ModifyClimate()
        {
            State.temperatureC = Mathf.Lerp(State.temperatureC, 18f, 0.28f);
            State.atmosphere = Mathf.Clamp01(State.atmosphere + 0.035f);
            State.water = Mathf.Clamp01(State.water + 0.012f);
            LastEvent = "Semeadores atmosféricos estabilizaram o clima.";
            Notify();
        }

        public void IntroduceLife()
        {
            if (Habitability() < 0.42f)
            {
                LastEvent = "A biosfera não se fixou: condições ainda hostis.";
                Notify();
                return;
            }

            State.biodiversity = Mathf.Clamp01(Mathf.Max(State.biodiversity, 0.22f) + 0.06f);
            State.ageYears = Math.Max(State.ageYears, 1_250_000_000d);
            LastEvent = "Primeiras colônias biológicas foram introduzidas.";
            Notify();
        }

        public void Terraform()
        {
            State.atmosphere = Mathf.Lerp(State.atmosphere, 0.82f, 0.42f);
            State.temperatureC = Mathf.Lerp(State.temperatureC, 18f, 0.42f);
            State.water = Mathf.Lerp(State.water, 0.61f, 0.34f);
            State.minerals = Mathf.Clamp01(State.minerals - 0.06f);
            LastEvent = "Terraformação em larga escala alterou a superfície.";
            Notify();
        }

        public void Evolve()
        {
            State.biodiversity = Mathf.Clamp01(State.biodiversity + 0.09f * Habitability());
            if (State.biodiversity > 0.62f)
                State.civilization = Mathf.Clamp01(State.civilization + 0.045f);
            State.ageYears += 85_000_000d;
            LastEvent = "A evolução foi acelerada por milhões de anos.";
            Notify();
        }

        public void Research()
        {
            State.research = Mathf.Clamp01(State.research + 0.08f);
            State.minerals = Mathf.Clamp01(State.minerals + 0.02f);
            LastEvent = "Pesquisa orbital revelou novos padrões planetários.";
            Notify();
        }

        public void CreateNewWorld()
        {
            int nextSeed = UnityEngine.Random.Range(1000, 999999);
            State = new WorldState
            {
                worldName = "Aurora " + UnityEngine.Random.Range(2, 99),
                ageYears = 85_000_000d,
                massEarth = UnityEngine.Random.Range(0.72f, 1.42f),
                atmosphere = UnityEngine.Random.Range(0.18f, 0.52f),
                temperatureC = UnityEngine.Random.Range(54f, 210f),
                water = UnityEngine.Random.Range(0.02f, 0.18f),
                biodiversity = 0f,
                civilization = 0f,
                orbitAU = UnityEngine.Random.Range(0.78f, 1.32f),
                research = 0.02f,
                minerals = UnityEngine.Random.Range(0.28f, 0.62f),
                seed = nextSeed
            };
            TimeScale = 1f;
            LastEvent = "Novo mundo condensado a partir de matéria cósmica.";
            Notify();
        }

        public void CycleTimeScale()
        {
            if (TimeScale < 2f) TimeScale = 10f;
            else if (TimeScale < 20f) TimeScale = 100f;
            else if (TimeScale < 200f) TimeScale = 1000f;
            else TimeScale = 1f;

            LastEvent = "Velocidade temporal: " + TimeScale.ToString("0") + "x.";
            Notify();
        }

        public void NudgeAge(double years)
        {
            State.ageYears = Math.Max(0d, State.ageYears + years);
            Notify();
        }

        void Notify()
        {
            RecalculateEra();
            Changed?.Invoke();
        }

        void RecalculateEra()
        {
            double a = State.ageYears;

            int era;
            double start;
            double end;

            if (a < 20_000_000d) { era = 0; start = 0d; end = 20_000_000d; }
            else if (a < 120_000_000d) { era = 1; start = 20_000_000d; end = 120_000_000d; }
            else if (a < 600_000_000d) { era = 2; start = 120_000_000d; end = 600_000_000d; }
            else if (a < 1_200_000_000d) { era = 3; start = 600_000_000d; end = 1_200_000_000d; }
            else if (a < 2_200_000_000d) { era = 4; start = 1_200_000_000d; end = 2_200_000_000d; }
            else if (a < 3_050_000_000d) { era = 5; start = 2_200_000_000d; end = 3_050_000_000d; }
            else if (a < 3_800_000_000d) { era = 6; start = 3_050_000_000d; end = 3_800_000_000d; }
            else if (a < 4_550_000_000d) { era = 7; start = 3_800_000_000d; end = 4_550_000_000d; }
            else { era = 8; start = 4_550_000_000d; end = 5_500_000_000d; }

            EraIndex = era;
            EraProgress = Mathf.Clamp01((float)((a - start) / Math.Max(1d, end - start)));
        }
    }
}

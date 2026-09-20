package com.noveceus.universe;

import java.util.Locale;
import java.util.Random;

public final class Simulation {
    public static final String[] ERAS = {
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

    public String name = "Aurora Prime";
    public double ageYears = 720_000_000d;
    public float massEarth = 1.00f;
    public float atmosphere = 0.78f;
    public float temperature = 16f;
    public float water = 0.71f;
    public float biodiversity = 0.18f;
    public float civilization = 0.04f;
    public float orbitAu = 1.00f;
    public float minerals = 0.35f;
    public float research = 0.08f;
    public float timeScale = 1f;
    public int seed = 9137;
    public String lastEvent = "Um mundo desperta entre as estrelas.";

    private final Random random = new Random(88031L);

    public synchronized void step(double realSeconds) {
        double years = 240_000d * realSeconds * timeScale;
        ageYears += years;

        float step = (float)Math.min(years / 5_000_000d, 0.15d);
        int era = eraIndex();
        float hab = habitability();

        if (era >= 3) {
            atmosphere = clamp01(atmosphere + 0.0008f * step);
        }
        if (era >= 4 && hab > 0.44f) {
            biodiversity = clamp01(biodiversity + (0.0016f + 0.003f * hab) * step);
        }
        if (era >= 7 && biodiversity > 0.55f) {
            civilization = clamp01(civilization + 0.0018f * step * biodiversity);
            research = clamp01(research + 0.0012f * step * civilization);
        }

        if (random.nextFloat() < 0.00035f * Math.sqrt(Math.max(1f, timeScale)) * realSeconds) {
            naturalEvent();
        }
    }

    public synchronized float habitability() {
        float tempScore = 1f - clamp01(Math.abs(temperature - 18f) / 95f);
        float waterScore = 1f - Math.abs(water - 0.58f);
        float atmScore = 1f - Math.abs(atmosphere - 0.80f);
        float orbitScore = 1f - clamp01(Math.abs(orbitAu - 1f) / 1.5f);
        return clamp01(tempScore * 0.32f + waterScore * 0.24f + atmScore * 0.22f + orbitScore * 0.22f);
    }

    public synchronized int eraIndex() {
        double a = ageYears;
        if (a < 20_000_000d) return 0;
        if (a < 120_000_000d) return 1;
        if (a < 600_000_000d) return 2;
        if (a < 1_200_000_000d) return 3;
        if (a < 2_200_000_000d) return 4;
        if (a < 3_050_000_000d) return 5;
        if (a < 3_800_000_000d) return 6;
        if (a < 4_550_000_000d) return 7;
        return 8;
    }

    public synchronized float eraProgress() {
        double a = ageYears;
        double start;
        double end;
        int e = eraIndex();
        switch (e) {
            case 0: start = 0; end = 20_000_000d; break;
            case 1: start = 20_000_000d; end = 120_000_000d; break;
            case 2: start = 120_000_000d; end = 600_000_000d; break;
            case 3: start = 600_000_000d; end = 1_200_000_000d; break;
            case 4: start = 1_200_000_000d; end = 2_200_000_000d; break;
            case 5: start = 2_200_000_000d; end = 3_050_000_000d; break;
            case 6: start = 3_050_000_000d; end = 3_800_000_000d; break;
            case 7: start = 3_800_000_000d; end = 4_550_000_000d; break;
            default: start = 4_550_000_000d; end = 5_500_000_000d; break;
        }
        return clamp01((float)((a - start) / Math.max(1d, end - start)));
    }

    public synchronized String eraName() {
        return ERAS[eraIndex()];
    }

    public synchronized void adjustOrbit() {
        if (temperature > 30f) orbitAu = Math.min(1.75f, orbitAu + 0.08f);
        else if (temperature < 4f) orbitAu = Math.max(0.62f, orbitAu - 0.06f);
        else orbitAu = Math.min(1.75f, orbitAu + 0.03f);
        temperature += (1f - orbitAu) * 7.5f;
        lastEvent = String.format(Locale.US, "Órbita recalibrada para %.2f UA.", orbitAu);
    }

    public synchronized void modifyClimate() {
        temperature = lerp(temperature, 18f, 0.30f);
        atmosphere = clamp01(atmosphere + 0.04f);
        water = clamp01(water + 0.012f);
        lastEvent = "Semeadores atmosféricos estabilizaram o clima.";
    }

    public synchronized void introduceLife() {
        if (habitability() < 0.42f) {
            lastEvent = "A biosfera não se fixou: condições ainda hostis.";
            return;
        }
        biodiversity = clamp01(Math.max(biodiversity, 0.22f) + 0.06f);
        ageYears = Math.max(ageYears, 1_250_000_000d);
        lastEvent = "Primeiras colônias biológicas foram introduzidas.";
    }

    public synchronized void terraform() {
        atmosphere = lerp(atmosphere, 0.82f, 0.42f);
        temperature = lerp(temperature, 18f, 0.42f);
        water = lerp(water, 0.61f, 0.34f);
        minerals = clamp01(minerals - 0.06f);
        lastEvent = "Terraformação remodelou atmosfera, água e continentes.";
    }

    public synchronized void evolve() {
        biodiversity = clamp01(biodiversity + 0.09f * habitability());
        if (biodiversity > 0.62f) civilization = clamp01(civilization + 0.045f);
        ageYears += 85_000_000d;
        lastEvent = "A evolução foi acelerada por milhões de anos.";
    }

    public synchronized void research() {
        research = clamp01(research + 0.08f);
        minerals = clamp01(minerals + 0.02f);
        lastEvent = "A estação orbital concluiu uma nova pesquisa.";
    }

    public synchronized void newWorld() {
        int n = 2 + random.nextInt(97);
        name = "Aurora " + n;
        ageYears = 85_000_000d;
        massEarth = 0.72f + random.nextFloat() * 0.70f;
        atmosphere = 0.18f + random.nextFloat() * 0.34f;
        temperature = 54f + random.nextFloat() * 156f;
        water = 0.02f + random.nextFloat() * 0.16f;
        biodiversity = 0f;
        civilization = 0f;
        orbitAu = 0.78f + random.nextFloat() * 0.54f;
        minerals = 0.28f + random.nextFloat() * 0.34f;
        research = 0.02f;
        timeScale = 1f;
        seed = 1000 + random.nextInt(998999);
        lastEvent = "Novo mundo condensado a partir de matéria cósmica.";
    }

    public synchronized void cycleTime() {
        if (timeScale < 2f) timeScale = 10f;
        else if (timeScale < 20f) timeScale = 100f;
        else if (timeScale < 200f) timeScale = 1000f;
        else timeScale = 1f;
        lastEvent = "Velocidade temporal: " + (int)timeScale + "x.";
    }

    public synchronized String civilizationLabel() {
        if (civilization < 0.08f) return "Primitiva";
        if (civilization < 0.25f) return "Tribal";
        if (civilization < 0.48f) return "Industrial";
        if (civilization < 0.72f) return "Planetária";
        if (civilization < 0.92f) return "Interplanetária";
        return "Estelar";
    }

    public synchronized String formattedAge() {
        if (ageYears >= 1_000_000_000d)
            return String.format(Locale.US, "%.2f bi anos", ageYears / 1_000_000_000d);
        if (ageYears >= 1_000_000d)
            return String.format(Locale.US, "%.0f mi anos", ageYears / 1_000_000d);
        return String.format(Locale.US, "%.0f anos", ageYears);
    }

    private void naturalEvent() {
        switch (random.nextInt(4)) {
            case 0:
                minerals = clamp01(minerals + 0.025f);
                lastEvent = "Chuva de meteoros trouxe minerais raros.";
                break;
            case 1:
                temperature += -1.8f + random.nextFloat() * 3f;
                lastEvent = "Oscilação estelar alterou o clima global.";
                break;
            case 2:
                water = clamp01(water - 0.015f + random.nextFloat() * 0.04f);
                lastEvent = "Cometas ricos em gelo cruzaram a órbita.";
                break;
            default:
                if (biodiversity > 0.08f) biodiversity = clamp01(biodiversity - 0.018f);
                lastEvent = "Atividade tectônica remodelou continentes.";
                break;
        }
    }

    private static float clamp01(float v) {
        return Math.max(0f, Math.min(1f, v));
    }

    private static float lerp(float a, float b, float t) {
        return a + (b - a) * t;
    }
}

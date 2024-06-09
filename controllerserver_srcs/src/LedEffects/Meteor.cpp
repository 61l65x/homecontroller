
/*#include "Arduino.h"
//#include "NightDriverHeaders/include/ledstripeffect.h"

class MeteorChannel
{
	vector<float> hue;
	vector<float> iPos;
	vector<bool>  bLeft;
	vector<float> speed;
	vector<double> lastBeat;

public:

	size_t        meteorCount;
	uint8_t       meteorSize;
	uint8_t       meteorTrailDecay;
	double        meteorSpeedMin;
	double        meteorSpeedMax;
	bool 	      meteorRandomDecay = true;
	const double  minTimeBetweenBeats = 0.6;

	MeteorChannel() 
	{
	
	}

	virtual void Init(LEDMatrixGFX * pGFX, size_t meteors = 4, uint size = 4, uint decay = 3, double minSpeed = 0.5, double maxSpeed = 0.5)
	{
		meteorCount = meteors;
		meteorSize = size;
		meteorTrailDecay = decay;
		meteorSpeedMin = minSpeed;
		meteorSpeedMax = maxSpeed;

		hue.resize(meteors);
		iPos.resize(meteors);
		bLeft.resize(meteors);
		speed.resize(meteors);
		lastBeat.resize(meteors);

		static int hueval = HUE_RED;
		for (int i = 0; i < meteorCount; i++)
		{
            hueval = hueval + 48;
            hueval %= 256;
			hue[i] = hueval;
			iPos[i] = (pGFX->GetLEDCount() / meteorCount) * i;
			//bLeft[i] = (bool) randomDouble(0, 1);
			speed[i] = randomDouble(meteorSpeedMin, meteorSpeedMax);
			lastBeat[i] = g_AppTime.FrameStartTime();
			bLeft[i] = i & 2;
		}
	}

	virtual void Reverse(int iMeteor)
	{
		bLeft[iMeteor] = !bLeft[iMeteor];
	}

	virtual void Draw(LEDMatrixGFX * pGFX)
	{
		static CHSV hsv;
		hsv.val = 255;
		hsv.sat = 240;

		for (int j = 0; j<pGFX->GetLEDCount(); j++)							// fade brightness all LEDs one step
        {
			if ((!meteorRandomDecay) || (randomDouble(0, 10)>2))			// BUGBUG Was 5 for everything before atomlight 
            {
                CRGB c = pGFX->getPixel(j, 0);
                c.fadeToBlackBy(meteorTrailDecay);
                pGFX->drawPixel(j, c);
            }
        }

			// If there's a beat to the music in a band, reverse the direction of the meteor indexed by the same number
					
		if (g_Beats.IsBeat[0] && (g_AppTime.FrameStartTime() - lastBeat[0] > minTimeBetweenBeats))
		{
			lastBeat[0] = g_AppTime.FrameStartTime();
			for (int j = 0; j < meteorCount; j++)
				Reverse(j);
		}
		
		for (int i = 0; i < meteorCount; i++)
		{
				
			iPos[i] = (bLeft[i]) ? iPos[i]-speed[i] * g_SoundInfo.gVURatio : iPos[i]+speed[i] * g_SoundInfo.gVURatio;
			if (iPos[i]< meteorSize)
			{
				bLeft[i] = false;
				iPos[i] = meteorSize;
			}
			if (iPos[i] >= pGFX->GetLEDCount())
			{
				bLeft[i] = true;
				iPos[i] = pGFX->GetLEDCount()-1;
			}

			for (int j = 0; j < meteorSize; j++)					// Draw the meteor head
			{
				if ((iPos[i] - j <= pGFX->GetLEDCount()) && (iPos[i] - j >= 1)) 
				{
					CRGB rgb;
					hue[i] = hue[i] + 0.025f;
					if (hue[i] > 255.0f)
						hue[i] -= 255.0f;
					hsv.hue = hue[i];
					hsv2rgb_rainbow(hsv, rgb);
					int x = iPos[i] - j;
                    nblend(pGFX->GetLEDBuffer()[x], rgb, 75);						
				}
			}
		}
	}
};

class MeteorEffect : public LEDStripEffect
{
  private:
	MeteorChannel   _Meteors[NUM_CHANNELS];
    LEDMatrixGFX  ** _gfx;

	int				_cMeteors;
	uint8_t         _meteorSize;
	uint8_t         _meteorTrailDecay;
	double          _meteorSpeedMin;
	double          _meteorSpeedMax;

  public:
  
    MeteorEffect(int cMeteors = 4, uint size = 4, uint decay = 3, double minSpeed = 0.5, double maxSpeed = 0.5) : LEDStripEffect("Color Meteors"), _Meteors()
    {
		_cMeteors = cMeteors;
		_meteorSize =  size;
		_meteorTrailDecay = decay;
		_meteorSpeedMin = minSpeed;
		_meteorSpeedMax = maxSpeed;
    }

    virtual bool Init(LEDMatrixGFX * gfx[NUM_CHANNELS])	
    {
        _gfx = gfx;
        if (!LEDStripEffect::Init(gfx))
            return false;
        for (int i = 0; i < ARRAYSIZE(_Meteors); i++)
            _Meteors[i].Init(gfx[i], _cMeteors, _meteorSize, _meteorTrailDecay, _meteorSpeedMin, _meteorSpeedMax);
        return true;
    }

	virtual void Draw() 
    {
        for (int i = 0; i < ARRAYSIZE(_Meteors); i++)
            _Meteors[i].Draw(_gfx[i]);
    }
	
    virtual const char * FriendlyName() const
    {
        return "Meteor Effect";
    }
};*/
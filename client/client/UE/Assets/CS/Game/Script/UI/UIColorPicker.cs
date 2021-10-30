using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using UnityEngine.EventSystems;

public class UIColorPicker : UIBehaviour{
    public UIColorLayer hue_layer_;
    public UIColorLayer saturation_layer_;
    public UIColorLayer brighness_layer_;
    public UIColorLayer alpha_layer_;
    private readonly Color[] HUE_COLOR = new Color[] { Color.red, Color.yellow, Color.green, Color.cyan, Color.blue, Color.magenta, Color.red };
    private readonly Color[] SATURATION_COLOR = new Color[] {Color.white, Color.red};
    private readonly Color[] BRIGHNESS_COLOR = new Color[] {Color.black, Color.white};
    private readonly Color[] ALPHA_COLOR = new Color[] {Color.black, Color.white};
    private CustomEventTrigger event_trigger_;

    protected override void Awake(){
        base.Awake();
        event_trigger_ = GetComponent<CustomEventTrigger>();
        if (hue_layer_ != null)
        {
            hue_layer_.SetColor(HUE_COLOR);
            hue_layer_.slider_.onValueChanged.AddListener(OnHudValueChange);
        }
        if (saturation_layer_ != null)
        {
            saturation_layer_.SetColor(SATURATION_COLOR);
            saturation_layer_.slider_.onValueChanged.AddListener(OnSaturationValueChange);
        }
        if (brighness_layer_ != null)
        {
            brighness_layer_.SetColor(BRIGHNESS_COLOR);
            brighness_layer_.slider_.onValueChanged.AddListener(OnBrighnessValueChange);
        }
        if (alpha_layer_ != null)
        {
            alpha_layer_.SetColor(ALPHA_COLOR);
            alpha_layer_.slider_.onValueChanged.AddListener(OnAlphaValueChange);
        }
    }

    public void SetHSVColor(Color color)
    {
        float h = color.r, s = color.g / 2, v = color.b / 2;
        hue_layer_.slider_.value = h;
        saturation_layer_.slider_.value = s;
        brighness_layer_.slider_.value = v;
        alpha_layer_.slider_.value = color.a;
    }

    public void SetRGBColor(Color color){
        float h = 0 , s = 0, v = 0;
        Color.RGBToHSV(color, out h, out s, out v);
        hue_layer_.slider_.value = h;
        saturation_layer_.slider_.value = s;
        brighness_layer_.slider_.value = v;
        alpha_layer_.slider_.value = color.a;
    }

    public Color GetHSVColor()
    {
        float h = hue_layer_.slider_.value;
        float s = saturation_layer_.slider_.value;
        float v = brighness_layer_.slider_.value;
        float a = alpha_layer_.slider_.value;
        Color color = new Color(h, s * 2, v * 2, a);
        return color;
    }

    public Color GetRGBColor()
    {
        float h = hue_layer_.slider_.value;
        float s = saturation_layer_.slider_.value;
        float v = brighness_layer_.slider_.value;
        float a = alpha_layer_.slider_.value;
        Color color = Color.HSVToRGB(h, s, v);
        color = new Color(color.r, color.g, color.b, a);
        return color;
    }
    
    protected void OnHudValueChange(float value)
    {
        UpdateLayerColor();
        TriggerEvent();
    }

    protected void OnSaturationValueChange(float value)
    {
        UpdateLayerColor();
        TriggerEvent();
    }

    protected void OnBrighnessValueChange(float value)
    {
        UpdateLayerColor();
        TriggerEvent();
    }

    protected void OnAlphaValueChange(float value)
    {
        TriggerEvent();
    }

    protected void UpdateLayerColor()
    {
        Color color1 = Color.HSVToRGB(hue_layer_.slider_.value, 0, brighness_layer_.slider_.value);
        Color color2 = Color.HSVToRGB(hue_layer_.slider_.value, 1, brighness_layer_.slider_.value);
        saturation_layer_.SetColor(new Color[] {color1, color2});
        color1 = Color.HSVToRGB(hue_layer_.slider_.value, saturation_layer_.slider_.value, 0);
        color2 = Color.HSVToRGB(hue_layer_.slider_.value, saturation_layer_.slider_.value, 1);
        brighness_layer_.SetColor(new Color[] {color1, color2});
    }

    protected void TriggerEvent(){
        event_trigger_.TriggerEvent("");
    }
}

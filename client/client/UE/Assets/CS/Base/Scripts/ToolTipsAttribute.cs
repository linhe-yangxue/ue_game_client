// Copyright (c) 2017 (weiwei)

[System.AttributeUsage(System.AttributeTargets.Field)]
public class ToolTipsAttribute : System.Attribute {
    #region Private Value Defines Begin
    protected string _tip_text_;
    protected string _dependent_property_;
    protected float _min_;
    protected float _max_;
    protected bool _has_range_ = false;
    protected string _alias_name_;
    protected System.Type _enum_type_;
    protected bool _dev_only_ = false;
    protected bool _allow_scene_objects_ = false;
    protected bool _is_scene_object_override_ = false;
    protected bool _treat_as_layer_ = false;
    protected bool _override_default_draw_ = false;
    #endregion // Private Value Defines End

    #region Public Inteface Defines Begin
    public ToolTipsAttribute(string tip_text, string alias_name = null, string dependent_property = null, System.Type enum_type = null, bool override_draw = false, bool dev_only = false) {
        _tip_text_ = tip_text;
        _alias_name_ = alias_name;
        _dependent_property_ = dependent_property;
        _enum_type_ = enum_type;
        _dev_only_ = dev_only;
        _override_default_draw_ = override_draw;
    }
    public ToolTipsAttribute(string tip_text, float min, float max, string alias_name = null, string dependent_property = null, bool override_draw = false, bool dev_only = false) {
        _tip_text_ = tip_text;
        _min_ = min;
        _max_ = max;
        _alias_name_ = alias_name;
        _dependent_property_ = dependent_property;
        _has_range_ = true;
        _dev_only_ = dev_only;
        _override_default_draw_ = override_draw;
    }
    public ToolTipsAttribute(string tip_text, bool allow_scene_objects, string alias_name = null, string dependent_property = null, bool override_draw = false, bool dev_only = false) {
        _tip_text_ = tip_text;
        _allow_scene_objects_ = allow_scene_objects;
        _alias_name_ = alias_name;
        _dependent_property_ = dependent_property;
        _dev_only_ = dev_only;
        _is_scene_object_override_ = true;
        _override_default_draw_ = override_draw;
    }
    public ToolTipsAttribute(string tip_text, string alias_name, bool treat_as_layer, string dependent_property = null, bool override_draw = false, bool dev_only = false) {
        _tip_text_ = tip_text;
        _alias_name_ = alias_name;
        _treat_as_layer_ = treat_as_layer;
        _dependent_property_ = dependent_property;
        _dev_only_ = dev_only;
        _override_default_draw_ = override_draw;
    }

    public string TipText                    {get {return _tip_text_;}}
    public string DependentProperty          {get {return _dependent_property_;}}
    public float Min                         {get {return _min_;}}
    public float Max                         {get {return _max_;}}
    public bool HasRange                     {get {return _has_range_;}}
    public string AliasName                  {get {return _alias_name_;}}
    public System.Type EnumType              {get {return _enum_type_;}}
    public bool DevOnly                      {get {return _dev_only_;}}
    public bool IsSceneObjectOverride        {get {return _is_scene_object_override_;}}
    public bool AllowSceneObjects            {get {return _allow_scene_objects_;}}
    public bool TreatAsLayer                 {get {return _treat_as_layer_;}}
    public bool OverrideDefaultDraw          {get {return _override_default_draw_;}}
    #endregion // Public Inteface Defines End
}

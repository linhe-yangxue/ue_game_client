using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;
using SLua;

namespace AssetBundles {
    public class ABLoadOptBase : LoadOperationBase {
        [DoNotToLua]
        public delegate void Callback(Object asset);

        protected AsyncOperation _sync_opt_ = null;
        protected Object _asset = null;
        [DoNotToLua]
        public Callback callback = null;

        public ABLoadOptBase(AsyncOperation _sync_opt) {
            _sync_opt_ = _sync_opt;
        }
        public override bool IsDone() {
            return _sync_opt_.isDone;
        }
        public override float progress { get {return _sync_opt_.progress; } }
        public override bool allowSceneActivation {
            get { return _sync_opt_.allowSceneActivation; }
            set { _sync_opt_.allowSceneActivation = value; }
        }
        public override Object asset {
            get {
                if (_asset != null) { return _asset; }
                AssetBundleRequest ab_r = _sync_opt_ as AssetBundleRequest;
                if (ab_r == null) { return null; }
                _asset = ab_r.asset;
                return _asset;
            }
        }
    }

    // Simulation
    public class ABLoadSimulationOpt : ABLoadOptBase {
        protected bool _is_active_;
        public ABLoadSimulationOpt(Object asset, bool is_active = false) : base(null) {
            _asset = asset;
            _is_active_ = is_active;
        }
        public override bool IsDone() { return true; }
        public override float progress { get { return 1; } }
        public override bool allowSceneActivation {
            get { return _is_active_; }
            set { _is_active_ = value; }
        }
        public override Object asset {
            get {return _asset;}
        }
    }

    public class ABLoadSubAssetOpt : ABLoadOptBase {
        string _sub_asset_name_;
        System.Type _asset_type_;
        public ABLoadSubAssetOpt(AsyncOperation _sync_opt, string sub_asset_name, System.Type asset_type)
            : base(_sync_opt) {
            _sub_asset_name_ = sub_asset_name.ToLower();
            _asset_type_ = asset_type;
        }
        public override Object asset {
            get {
                if (_asset != null) { return _asset; }
                AssetBundleRequest ab_r = _sync_opt_ as AssetBundleRequest;
                if (ab_r == null) { return null; }
                foreach (var asset in ab_r.allAssets) {
                    if (asset.GetType() == _asset_type_ && asset.name.ToLower() == _sub_asset_name_) {
                        _asset = asset;
                        break;
                    }
                }
                return _asset;
            }
        }
    }
}

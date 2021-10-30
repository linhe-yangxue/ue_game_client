local UISliderTween = class("UI.UISliderTween")

--  ui滚动条动画
function UISliderTween:DoInit(ui_image, duration)
    self.is_run = false
    self.duration = duration
    self.slider = ui_image
end

--  结果值 动画圈数
function UISliderTween:SetTargetVal(val, fill_time)
    if self.is_run then
        self.slider.fillAmount = self.end_fill_amount
    end
    self.is_run = true
    self.start_val = self.slider.fillAmount
    self.end_fill_amount = val
    self.end_val = val + fill_time
    self.fill_time = fill_time
    self.timer = 0
end

function UISliderTween:Update(delta_time)
    self.timer = self.timer + delta_time
    if self.timer > self.duration then
        self.slider.fillAmount = self.end_fill_amount
        self.is_run = false
    else
        local val = tween.easing.linear(self.timer, self.start_val, self.end_val - self.start_val, self.duration)

        if val > 1 then
            val = val % 1
        end
        self.slider.fillAmount = val
    end
end

return UISliderTween

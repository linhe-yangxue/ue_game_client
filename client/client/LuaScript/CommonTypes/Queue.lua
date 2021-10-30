local setmetatable = setmetatable
local getmetatable = getmetatable
local rawget = rawget
local rawset = rawset

Queue =
{
    __typename = "Queue",  -- 注意__typename是C#中识别类型的凭证
}

setmetatable(Queue, Queue)

Queue.__index = Queue


Queue.__call = function()
    return Queue.New()
end

function Queue.New()
    local q = {front = 0, rear = 0, count = 0}
    setmetatable(q, Queue)
    return q
end

function Queue:Enqueue(data)
    if self.count == 0 then
        self.front = self.front + 1
        self.rear = self.rear + 1
    else
        self.rear = self.rear + 1
    end
    self[self.rear] = data
    self.count = self.count + 1
end

function Queue:Dequeue(d_count)
    d_count = d_count == nil and 1 or d_count
    d_count = d_count > self.count and self.count or d_count
    if self.count == 0 then
        return nil
    else
        local tmp = nil
        while d_count > 0 do
            local front = self.front
            d_count = d_count - 1
            tmp = self[front]
            self[front] = nil
            self.count = self.count - 1
            if self.count == 0 then
                self.front = 0
                self.rear = 0
            else
                self.front = front + 1
            end
        end
        return tmp
    end
end

function Queue:First()
    if self.count > 0 then
        return self[self.front]
    end
end

function Queue:End()
    if self.count > 0 then
        return self[self.rear]
    end
end

function Queue:Get(idx)
    if idx > self.count then
        return
    end
    return self[self.front + idx - 1]
end

function Queue:Count()
    return self.count
end

function Queue:Clear()
    if self.count > 0 then
        local idx = self.front
        while idx <= self.rear do
            self[idx] = nil
            idx = idx + 1
        end
        self.count = 0
        self.front = 0
        self.rear = 0
    end
end

using System;
using System.Collections.Generic;
using System.IO;
using System.Text;

class MockSocketStream : System.IO.Stream
{
    SimplePipeline _out_stream;
    SimplePipeline _in_stream;

    public MockSocketStream()
    {
        _out_stream = new SimplePipeline(1024);
        _in_stream = new SimplePipeline(4096);
    }

    public override bool CanRead
    {
        get
        {
            return true;
        }
    }

    public override bool CanSeek
    {
        get
        {
            return false;
        }
    }

    public override bool CanTimeout
    {
        get
        {
            return false;
        }
    }

    public override bool CanWrite
    {
        get
        {
            return true;
        }
    }

    public override long Length
    {
        get
        {
            throw new NotImplementedException();
        }
    }

    public override long Position
    {
        get { throw new NotImplementedException(); }
        set
        {
            throw new NotImplementedException();
        }
    }

    public override void Flush()
    {
        return;
    }

    // 没数据时可能卡住
    // 子线程调用
    public override int Read(byte[] buffer, int offset, int count)
    {
        return _in_stream.ReadBytes(buffer, offset, count);
    }

    public override long Seek(long offset, SeekOrigin origin)
    {
        throw new NotImplementedException();
    }

    public override void SetLength(long value)
    {
        throw new NotImplementedException();
    }

    // 认证阶段子线程调用
    // 后面主线程调用
    public override void Write(byte[] buffer, int offset, int count)
    {
        _out_stream.WriteBytes(buffer, offset, count);
    }

    // 模拟server塞数据进去in_stream
    // 主线程调用
    public void MockServerSend(byte[] bytes, int offset, int count)
    {
        _in_stream.WriteBytes(bytes, offset, count);
    }

    // 模拟server从out_stream取走数据，没数据的话返回NULL
    // 主线程调用
    public byte[] MockServerRecv()
    {
        int size = _out_stream.GetReadLength();
        if(size > 0)
        {
            byte[] bytes = new byte[size];
            _out_stream.ReadBytes(bytes, 0, size);
            return bytes;
        }
        return null;
    }

    public void Destroy()
    {
        _in_stream.Destroy();
        _out_stream.Destroy();
    }
}


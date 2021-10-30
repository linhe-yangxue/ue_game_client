using System;
using System.Collections.Generic;
using System.Text;
using System.Threading;

// 支持多线程读写
class SimplePipeline
{
    int buffer_length;
    List<byte[]> buffer_list;
    int read_pos;
    int write_pos;
    int capacity;
    bool is_quit;

    object _locker;
    AutoResetEvent _event;

    public SimplePipeline(int buffer_length)
    {
        _locker = new object();
        _event = new AutoResetEvent(false);

        is_quit = false;
        this.buffer_length = buffer_length;
        read_pos = 0;
        write_pos = 0;
        capacity = 0;
        buffer_list = new List<byte[]>();
        _increase_buffer(buffer_length);
    }

    public int GetReadLength()
    {
        lock(_locker)
        {
            return write_pos - read_pos;
        }
    }

    public void Destroy()
    {
        lock(_locker)
        {
            is_quit = true;
        }
        _event.Set();
    }

    public void WriteBytes(byte[] bytes, int offset, int count)
    {
        if (bytes == null)
            throw new ArgumentNullException("bytes is null");
        if (offset < 0)
            throw new ArgumentOutOfRangeException("offset < 0");
        if (count < 0)
            throw new ArgumentOutOfRangeException("count < 0");
        if (offset + count > bytes.Length)
        {
            throw new ArgumentException("The sum of offset and count is greater than the buffer length");
        }
        if (count <= 0)
        {
            return;
        }

        lock(_locker)
        {
            _increase_buffer(count);

            int copyed = 0;
            while(copyed < count)
            {
                int free_bytes = buffer_length - (write_pos % buffer_length);
                int copy_count;
                if(free_bytes >= (count - copyed))
                {
                    copy_count = count - copyed;
                }
                else
                {
                    copy_count = free_bytes;
                }
                Buffer.BlockCopy(bytes, offset+copyed, buffer_list[write_pos / buffer_length], write_pos % buffer_length, copy_count);
                write_pos += copy_count;
                copyed += copy_count;
            }
        }
        _event.Set();
    }

    /// <summary>
    /// 读取数据, 没数据的话会卡住线程
    /// </summary>
    public int ReadBytes(byte[] buffer, int offset, int count)
    {
        if (buffer == null)
            throw new ArgumentNullException("bytes is null");
        if (offset < 0)
            throw new ArgumentOutOfRangeException("offset < 0");
        if (count < 0)
            throw new ArgumentOutOfRangeException("count < 0");
        if (offset + count > buffer.Length)
        {
            throw new ArgumentException("The sum of offset and count is greater than the buffer length");
        }

        while(true)
        {
            lock (_locker)
            {
                if(is_quit)
                {
                    return 0;
                }
                if(read_pos >= write_pos)
                {
                    // 没数据， 不应该出现这种情况，但也ok
                }
                else
                {
                    int copyed = 0;
                    while (copyed < count && read_pos < write_pos)
                    {
                        int unread_bytes = Math.Min(write_pos - read_pos, buffer_length - (read_pos % buffer_length));
                        int copy_count;
                        if (unread_bytes <= count - copyed)
                        {
                            copy_count = unread_bytes;
                        }
                        else
                        {
                            copy_count = count - copyed;
                        }
                        Buffer.BlockCopy(buffer_list[read_pos / buffer_length], read_pos % buffer_length, buffer, offset + copyed, copy_count);
                        read_pos += copy_count;
                        copyed += copy_count;
                    }
                    _decrease_buffer();
                    return copyed;
                }
            }
            _event.WaitOne();
        }
    }

    private void _increase_buffer(int need_free_bytes)
    {
        while (need_free_bytes > capacity - write_pos)
        {
            buffer_list.Add(new byte[buffer_length]);
            capacity += buffer_length;
        }
    }

    private void _decrease_buffer()
    {
        while (read_pos >= buffer_length && capacity > buffer_length)
        {
            buffer_list.RemoveAt(0);
            capacity -= buffer_length;
            read_pos -= buffer_length;
            write_pos -= buffer_length;
        }
    }
}

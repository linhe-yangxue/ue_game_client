using System;
using System.Collections.Generic;
using System.Text;
using System.IO;
using System.Net.Security;
using System.Security.Cryptography;
using System.Security.Cryptography.X509Certificates;

public class MockSsl
{
    public delegate void authDelegate(string targetName);
    public delegate int recvDelegate();

    MockSocketStream sock;
    SslStream ssl;

    IAsyncResult auth_result;
    authDelegate auth_caller;
    bool auth_complete;

    byte[] cached_send;
    byte[] recv_buffer;
    int recv_buff_size;

    recvDelegate recv_caller;
    IAsyncResult recv_result;

    bool destroyed;

    public MockSsl()
    {
        auth_complete = false;
        auth_result = null;
        auth_caller = null;
        cached_send = null;

        recv_caller = null;
        recv_result = null;

        recv_buff_size = 1024 * 100;
        recv_buffer = new byte[recv_buff_size];

        destroyed = false;
    }

    public void Destroy()
    {
        if(!destroyed)
        {
            destroyed = true;
            sock.Destroy();
            ssl.Close();
            ssl.Dispose();
        }
    }

    public static bool check_(X509Certificate c)
    {
        MD5 m = MD5.Create();
        byte[] data = c.GetPublicKey();
        byte[] dou_data = new byte[data.Length * 2];
        for(int i=0; i<data.Length; i++)
        {
            dou_data[i * 2] = data[i];
            dou_data[i * 2 + 1] = (byte)(data[i] >> 1 + 3);
        }
        data = m.ComputeHash(dou_data);
        StringBuilder sBuilder = new StringBuilder();

        // Loop through each byte of the hashed data 
        // and format each one as a hexadecimal string.
        for (int i = 0; i < data.Length; i++)
        {
            sBuilder.Append(data[i].ToString("x2"));
        }

        return sBuilder.ToString() == "1156a0a975fdd1f52badcaf1f7cae564";
    }

    public static bool ValidateServerCertificate(
             object sender,
             X509Certificate certificate,
             X509Chain chain,
             SslPolicyErrors sslPolicyErrors)
    {
        //if (sslPolicyErrors == SslPolicyErrors.None)
        //    return true;

        if(check_(certificate))
        {
            return true;
        }

        Debugger.Log("Certificate error: {0}", sslPolicyErrors);

        return false;
    }

    public void Init(string targetHost)
    {
        BeginAuthenticate(targetHost);
    }

    public void BeginAuthenticate(string targetHost)
    {
        if(auth_caller == null)
        {
            sock = new MockSocketStream();
            ssl = new SslStream(sock, true,
                new RemoteCertificateValidationCallback(ValidateServerCertificate),
                null);
            cached_send = null;
            auth_caller = new authDelegate(ssl.AuthenticateAsClient);
            auth_result = auth_caller.BeginInvoke(targetHost, null, null);
        }
        else
        {
            throw new ArgumentException("already is authenticating");
        }
    }

    public bool CheckAuthenticate()
    {
        if(auth_complete)
        {
            return true;
        }
        if(auth_caller == null)
        {
            throw new ArgumentException("isnot authenticating");
        }
        else
        {
            if(auth_result.IsCompleted)
            {
                auth_complete = true;
                auth_caller.EndInvoke(auth_result);
                auth_result.AsyncWaitHandle.Close();
                auth_caller = null;
                auth_result = null;

                //Debugger.Log("Cipher: {0} strength {1}, {2}", ssl.CipherAlgorithm, ssl.CipherStrength, destroyed);
                //Debugger.Log("Hash: {0} strength {1}", ssl.HashAlgorithm, ssl.HashStrength);
                //Debugger.Log("Key exchange: {0} ", ssl.KeyExchangeAlgorithm);
                //Debugger.Log("Protocol: {0}", ssl.SslProtocol);

                byte[] data = cached_send;
                cached_send = null;
                if(data != null && data.Length > 0)
                {
                    Send(data, 0, data.Length);
                }
                return true;
            }
            return false;
        }
    }

    public int _recv()
    {
        int size = ssl.Read(recv_buffer, 0, recv_buff_size);
        return size;
    }

    public void _begin_recv()
    {
        recv_caller = new recvDelegate(_recv);
        recv_result = recv_caller.BeginInvoke(null, null);
    }

    public byte[] Recv()
    {
        if(!auth_complete)
        {
            return null;
        }
        if (recv_caller == null)
        {
            _begin_recv();
        }

        MemoryStream data = new MemoryStream();
        while (recv_result.IsCompleted)
        {
            int size = recv_caller.EndInvoke(recv_result);
            if(size > 0)
            {
                data.Write(recv_buffer, 0, size);
                recv_caller = null;
                recv_result = null;
                _begin_recv();
            }
        }
        
        if(data.Length == 0)
        {
            return null;
        }
        return data.ToArray();
    }

    public void Send(byte[] bytes, int offset, int count)
    {
        if (offset + count > bytes.Length)
        {
            throw new ArgumentException("The sum of offset and count is greater than the bytes length");
        }
        if (!auth_complete)
        {
            if(cached_send == null)
            {
                cached_send = bytes;
            }
            else
            {
                byte[] all_data = new byte[cached_send.Length + count];
                Buffer.BlockCopy(cached_send, 0, all_data, 0, cached_send.Length);
                Buffer.BlockCopy(bytes, offset, all_data, cached_send.Length, count);
                cached_send = all_data;
            }
            return;
        }
        
        ssl.Write(bytes, 0, count);
    }

    public void MockServerSend(byte[] bytes, int offset, int count)
    {
        sock.MockServerSend(bytes, offset, count);
    }

    public byte[] MockServerRecv()
    {
        return sock.MockServerRecv();
    }

    public void Update()
    {
        CheckAuthenticate();
    }

}


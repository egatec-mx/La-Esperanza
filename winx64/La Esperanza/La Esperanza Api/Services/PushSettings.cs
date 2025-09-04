namespace LaEsperanza.Api.Services
{
    public class ApplePushSettings
    {
        public string Bundle { get; set; }
        public string Key { get; set; }
        public string P8 { get; set; }
        public string Server { get; set; }
        public string Team { get; set; }
    }

    public class PushSettings
    {
        public string PrivateKey { get; set; }
        public string PublicKey { get; set; }
    }
}
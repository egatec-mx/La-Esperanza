using System.Threading.Tasks;

namespace LaEsperanza.Api.Services
{
    public interface IPushService
    {
        Task SendToAllDevicesAsync(string title, string message);

        Task SendToAndroidAsync(string title, string message);

        Task SendToAppleAsync(string pushTitle, string pushMessage);
    }
}
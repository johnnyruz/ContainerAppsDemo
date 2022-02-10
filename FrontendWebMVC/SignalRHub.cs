using System;
using System.Web;
using Microsoft.AspNetCore.SignalR;
namespace FrontendWebMVC
{
    public class SignalRHub : Hub
    {
        public async Task Send(string? messageId)
        {
            // Call the addNewMessageToPage method to update clients.
            await Clients.All.SendAsync("MessageProcessed", messageId);
        }
    }
}
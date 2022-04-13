using Dapr;
using Dapr.Client;
using FrontendWebMVC.Models;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.SignalR;
using System.Diagnostics;

namespace FrontendWebMVC.Controllers
{
    public class HomeController : Controller
    {
        private readonly ILogger<HomeController> _logger;
        private readonly DaprClient _dapr;
        private readonly IHubContext<SignalRHub> _signalR;

        public HomeController(ILogger<HomeController> logger, DaprClient dapr, IHubContext<SignalRHub> signalR)
        {
            _logger = logger;
            _dapr = dapr;
            _signalR = signalR;
        }

        public IActionResult Index()
        {
            return View();
        }

        public async Task<IActionResult> Publish()
        {
            var msg = await PublishMessage();
            return Ok(msg == null ? 0 : 1);
        }

        public async Task<IActionResult> Publish100()
        {
            int i = 0;
            DaprMessage? msg = new DaprMessage() { MessageId = "Init" };
            while (i < 100 && msg != null)
            {
                msg = await PublishMessage();
                i++;
            }
            return Ok(msg == null ? 0 : i);
        }

        [Topic("servicebus-pubsub", "messageresponsetopic")]
        [HttpPost("/messageprocessed")]
        public async Task<ActionResult> MessageProcessed([FromBody] DaprMessage daprMessage)
        {
            _logger.LogInformation($"Received Message Reponse Info! {daprMessage.MessageId}");
            await _signalR.Clients.All.SendAsync("MessageProcessed", 1);
            return Ok();
        }

        [ResponseCache(Duration = 0, Location = ResponseCacheLocation.None, NoStore = true)]
        public IActionResult Error()
        {
            return View(new ErrorViewModel { RequestId = Activity.Current?.Id ?? HttpContext.TraceIdentifier });
        }

        private async Task<DaprMessage?> PublishMessage()
        {
            var msg = new DaprMessage()
            {
                MessageId = Guid.NewGuid().ToString()
            };

            try
            {
                await _dapr.PublishEventAsync<DaprMessage>("servicebus-pubsub", "messagepublishtopic", msg);
                return msg;
            }
            catch(Exception e)
            {
                _logger.LogError(e.Message);
                return null;
            }
        }

        public class DaprMessage
        {
            public string? MessageId { get; set; }
        }


    }
}
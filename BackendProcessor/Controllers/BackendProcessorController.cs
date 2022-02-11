using Dapr;
using Dapr.Client;
using Microsoft.AspNetCore.Mvc;

namespace BackendProcessor.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class BackendProcessorController : ControllerBase
    {
        private readonly ILogger<BackendProcessorController> _logger;
        private readonly DaprClient _dapr;

        public BackendProcessorController(ILogger<BackendProcessorController> logger, DaprClient dapr)
        {
            _logger = logger;
            _dapr = dapr;
        }

        [Topic("servicebus-pubsub-backend", "messagepublishtopic")]
        [HttpPost("/processmessage")]
        public async Task<ActionResult> ProcessMessage([FromBody] DaprMessage daprMessage)
        {
            _logger.LogInformation($"Received Message Bus Info! {daprMessage.MessageId}");
            await Task.Delay(1000);
            await _dapr.PublishEventAsync<DaprMessage>("servicebus-pubsub-backend", "messageresponsetopic", daprMessage);
            return Ok();
        }

        public class DaprMessage
        {
            public string MessageId { get; set; }
        }
    }
}
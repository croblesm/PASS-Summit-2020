using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
using geo_kids_web_net.Models;
using Microsoft.EntityFrameworkCore;

namespace geo_kids_web_net.Controllers
{
    public class ContinentsController : Controller
    {
        private readonly ILogger<ContinentsController> _logger;

        private readonly DemoContext _context;

        public ContinentsController(ILogger<ContinentsController> logger, DemoContext context)
        {
            _context = context;
            _logger = logger;
        }

        public IActionResult Index()
        {
            var continents = _context.Continents.ToList();

            ViewBag.continents = continents;
            return View();
        }

        [ResponseCache(Duration = 0, Location = ResponseCacheLocation.None, NoStore = true)]
        public IActionResult Error()
        {
            return View(new ErrorViewModel { RequestId = Activity.Current?.Id ?? HttpContext.TraceIdentifier });
        }
    }
}

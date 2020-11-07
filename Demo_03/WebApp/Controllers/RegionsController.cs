using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
using geo_kids_web_net.Models;
using Microsoft.EntityFrameworkCore;
using System.Dynamic;

namespace geo_kids_web_net.Controllers
{
    public class RegionsController : Controller
    {
        private readonly ILogger<RegionsController> _logger;

        private readonly DemoContext _context;

        public RegionsController(ILogger<RegionsController> logger, DemoContext context)
        {
            _context = context;
            _logger = logger;
        }

        public IActionResult Index()
        {
            var regions = (from r in _context.Regions
            join c in _context.Continents on r.continent_id equals c.continent_id
            orderby c.continent_id ascending
            select new{
                r.region_id,
                r.region,
                c.continent
            }).ToList();

            ViewBag.regions = regions.Select(v =>{
                dynamic eo = new ExpandoObject();
                eo.region_id = v.region_id;
                eo.region = v.region;
                eo.continent = v.continent;
                return eo;
            }).ToArray();
            return View();
        }

        public IActionResult Details(int id)
        {
            var regions = (from r in _context.Regions
            join c in _context.Continents on r.continent_id equals c.continent_id
            where c.continent_id == id
            orderby c.continent_id ascending
            select new{
                r.region_id,
                r.region,
                c.continent
            }).ToList();

            ViewBag.regions = regions.Select(v =>{
                dynamic eo = new ExpandoObject();
                eo.region_id = v.region_id;
                eo.region = v.region;
                eo.continent = v.continent;
                return eo;
            }).ToArray();
            return View();
        }

        [ResponseCache(Duration = 0, Location = ResponseCacheLocation.None, NoStore = true)]
        public IActionResult Error()
        {
            return View(new ErrorViewModel { RequestId = Activity.Current?.Id ?? HttpContext.TraceIdentifier });
        }
    }
}

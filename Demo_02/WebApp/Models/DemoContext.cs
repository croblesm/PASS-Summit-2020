using System;
using geo_kids_web_net.Models;
using Microsoft.EntityFrameworkCore;

namespace geo_kids_web_net
{
    public class DemoContext : DbContext
    {
        public DemoContext(DbContextOptions<DemoContext> options)
            : base(options)
        { }

        public DbSet<Countries> Countries { get; set; }

        public DbSet<Continents> Continents { get; set; }

        public DbSet<Regions> Regions { get; set; }
    }
}
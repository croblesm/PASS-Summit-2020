using System;
using System.ComponentModel.DataAnnotations;

namespace geo_kids_web_net.Models
{
    public class Regions
    {
        [Key]
        public int region_id { get; set; }
        public string region { get; set; }
        public int continent_id { get; set; }
    }
}
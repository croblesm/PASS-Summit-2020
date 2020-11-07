using System;
using System.ComponentModel.DataAnnotations;

namespace geo_kids_web_net.Models
{
    public class Continents
    {
        [Key]
        public int continent_id { get; set; }
        public string continent { get; set; }
    }
}
using System;
using System.ComponentModel.DataAnnotations;

namespace geo_kids_web_net.Models
{
    public class Countries
    {
        [Key]
        public string country_id { get; set; }
        public string country { get; set; }
        public string un_m49 {get; set;}
        public int region_id {get; set;}
    }
}
using System.Collections.Generic;

namespace LaEsperanza.Api.Models
{
    public abstract class BaseModel
    {
        public string Message { get; set; }
        public List<string> Errors { get; set; }

        public BaseModel()
        {
            Message = string.Empty;
            Errors = new List<string>();
        }
    }
}
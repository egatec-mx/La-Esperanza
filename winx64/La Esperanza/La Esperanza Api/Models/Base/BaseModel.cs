using System.Collections.Generic;

namespace La_Esperanza_Api.Models.Base
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
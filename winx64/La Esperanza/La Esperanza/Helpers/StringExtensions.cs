using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace La_Esperanza.Helpers
{
    public static class StringExtensions
    {
        public static string CapitalFirstLetter(this string text)
        {
            return $"{text.Trim().Substring(0, 1).ToUpper()}{text.Trim().Substring(1).ToLower()}";
        }
    }
}

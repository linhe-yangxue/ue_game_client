using System;
using System.Collections.Generic;

namespace LT
{
    // class
    public class LTableAttribute : System.Attribute
    {
        public bool gen_by_self = false;
    }
    // member
    public class LTableMemberAttribute : System.Attribute
    {
        public int index = -1;
        public string name = null;
        public bool one_line = false;
    }
}

-- Math & MD5

on integerX(val)
  if val = "" then return 0
  return integer(val)
end

on integerXOne(val)
	val = integerX(val)
  if val = 0 then return 1
  return val
end

on integerXDefault(val, def)
	val = integerX(val)
  if val = 0 then return def
  return val
end

on isEvenNumber(theNum)
  if (theNum mod 2) = 0 then
    return TRUE
  else
    return FALSE
  end if

end

on roundUp(theFloat)

  if Integer(theFloat) - theFloat > 0 then
    return Integer(theFloat)
  else
    return Integer(theFloat) + 1
  end if

end

on roundDown(theFloat)

  if Integer(theFloat) - theFloat > 0 then
    return Integer(theFloat) - 1
  else
    return Integer(theFloat)
  end if

end

on LowerOf(a, base)

  if integer(a) < integer(base) then
    return integer(a)
  else
    return integer(base)
  end if

end

on HigherOf(a, base)

  if integer(a) > integer(base) then
    return integer(a)
  else
    return integer(base)
  end if

end

--"------------------------------------------------------
-- // Message Digester MD5
--------------------------------------------------------
--( public:
--(  <#string> CoMD5DigestFastest (<#string>)
--(
--( abstract:
--(   Fast lingo implementation of the MD5 algorithm.
--(   Implementation by Joni Huhmarniemi (21/2/2004).
--(   � 1991-2, RSA Data Security, Inc.
--( public )-- -- -- -- -- -- -- -- -- -- -- -- --//
--------------------------------------------------------
--( Returns the hex representation of string's MD5.
--( i:<#string>
--( o: -
--( r:<#string>
--------------------------------------------------------

on CoMD5DigestFastest(a_sInput)

  -- Convert string to list of little-endian words...

  t_iLen = length(a_sInput) * 8
  t_iCnt = (t_iLen + 64) / 512 * 16 + 16

  -- Create list, fill with zeros...

  x = []
  x.SetAt(t_iCnt, 0)

  t_fArr = [1, 256, 65536, 16777216]
  i = 0
  j = 0
  repeat while i < t_iLen
    j = j + 1
    t_iNext = i / 32 + 1
    t_iTemp = bitAnd(charToNum(char (i / 8 + 1) of a_sInput), 255) * t_fArr[j]
    x[t_iNext] = bitOr(x[t_iNext], t_iTemp)
    i = i + 8
    j = j mod 4
  end repeat

  -- Append padding...

  t_iNext = t_iLen / 32 + 1
  x[t_iNext] = bitOr(x[t_iNext], 128 * t_fArr[j + 1])
  x[(t_iLen + 64) / 512 * 16 + 15] = t_iLen

  -- Actual algorithm starts here...

  a =  1732584193
  b = -271733879
  c = -1732584194
  d =  271733878
  i =  1

  t_iWrap = the maxInteger + 1
  t_iCount = x.count + 1

  repeat while i < t_iCount

    olda = a
    oldb = b
    oldc = c
    oldd = d

    -- Round(1) --

    n = bitOr(bitAnd(b, c), bitAnd(bitNot(b), d)) + a + x[i] - 680876936
    if(n < 0) then
      a = bitOr(n * 128, bitOr((n + t_iWrap) / 33554432, 64)) + b
    else
      a = bitOr(n * 128, n / 33554432) + b
    end if

    n = bitOr(bitAnd(a, b), bitAnd(bitNot(a), c)) + d + x[i + 1] - 389564586
    if(n < 0) then
      d = bitOr(n * 4096, bitOr((n + t_iWrap) / 1048576, 2048)) + a
    else
      d = bitOr(n * 4096, n / 1048576) + a
    end if

    n = bitOr(bitAnd(d, a), bitAnd(bitNot(d), b)) + c + x[i + 2] + 606105819
    if(n < 0) then
      c = bitOr(n * 131072, bitOr((n + t_iWrap) / 32768, 65536)) + d
    else
      c = bitOr(n * 131072, n / 32768) + d
    end if

    n = bitOr(bitAnd(c, d), bitAnd(bitNot(c), a)) + b + x[i + 3] - 1044525330
    if(n < 0) then
      b = bitOr(n * 4194304, bitOr((n + t_iWrap) / 1024, 2097152)) + c
    else
      b = bitOr(n * 4194304, n / 1024) + c
    end if

    n = bitOr(bitAnd(b, c), bitAnd(bitNot(b), d)) + a + x[i + 4] - 176418897
    if(n < 0) then
      a = bitOr(n * 128, bitOr((n + t_iWrap) / 33554432, 64)) + b
    else
      a = bitOr(n * 128, n / 33554432) + b
    end if

    n = bitOr(bitAnd(a, b), bitAnd(bitNot(a), c)) + d + x[i + 5] + 1200080426
    if(n < 0) then
      d = bitOr(n * 4096, bitOr((n + t_iWrap) / 1048576, 2048)) + a
    else
      d = bitOr(n * 4096, n / 1048576) + a
    end if

    n = bitOr(bitAnd(d, a), bitAnd(bitNot(d), b)) + c + x[i + 6] - 1473231341
    if(n < 0) then
      c = bitOr(n * 131072, bitOr((n + t_iWrap) / 32768, 65536)) + d
    else
      c = bitOr(n * 131072, n / 32768) + d
    end if

    n = bitOr(bitAnd(c, d), bitAnd(bitNot(c), a)) + b + x[i + 7] - 45705983
    if(n < 0) then
      b = bitOr(n * 4194304, bitOr((n + t_iWrap) / 1024, 2097152)) + c
    else
      b = bitOr(n * 4194304, n / 1024) + c
    end if

    n = bitOr(bitAnd(b, c), bitAnd(bitNot(b), d)) + a + x[i + 8] + 1770035416
    if(n < 0) then
      a = bitOr(n * 128, bitOr((n + t_iWrap) / 33554432, 64)) + b
    else
      a = bitOr(n * 128, n / 33554432) + b
    end if

    n = bitOr(bitAnd(a, b), bitAnd(bitNot(a), c)) + d + x[i + 9] - 1958414417
    if(n < 0) then
      d = bitOr(n * 4096, bitOr((n + t_iWrap) / 1048576, 2048)) + a
    else
      d = bitOr(n * 4096, n / 1048576) + a
    end if

    n = bitOr(bitAnd(d, a), bitAnd(bitNot(d), b)) + c + x[i + 10] - 42063
    if(n < 0) then
      c = bitOr(n * 131072, bitOr((n + t_iWrap) / 32768, 65536)) + d
    else
      c = bitOr(n * 131072, n / 32768) + d
    end if

    n = bitOr(bitAnd(c, d), bitAnd(bitNot(c), a)) + b + x[i + 11] - 1990404162
    if(n < 0) then
      b = bitOr(n * 4194304, bitOr((n + t_iWrap) / 1024, 2097152)) + c
    else
      b = bitOr(n * 4194304, n / 1024) + c
    end if

    n = bitOr(bitAnd(b, c), bitAnd(bitNot(b), d)) + a + x[i + 12] + 1804603682
    if(n < 0) then
      a = bitOr(n * 128, bitOr((n + t_iWrap) / 33554432, 64)) + b
    else
      a = bitOr(n * 128, n / 33554432) + b
    end if

    n = bitOr(bitAnd(a, b), bitAnd(bitNot(a), c)) + d + x[i + 13] - 40341101
    if(n < 0) then
      d = bitOr(n * 4096, bitOr((n + t_iWrap) / 1048576, 2048)) + a
    else
      d = bitOr(n * 4096, n / 1048576) + a
    end if

    n = bitOr(bitAnd(d, a), bitAnd(bitNot(d), b)) + c + x[i + 14] - 1502002290
    if(n < 0) then
      c = bitOr(n * 131072, bitOr((n + t_iWrap) / 32768, 65536)) + d
    else
      c = bitOr(n * 131072, n / 32768) + d
    end if

    n = bitOr(bitAnd(c, d), bitAnd(bitNot(c), a)) + b + x[i + 15] + 1236535329
    if(n < 0) then
      b = bitOr(n * 4194304, bitOr((n + t_iWrap) / 1024, 2097152)) + c
    else
      b = bitOr(n * 4194304, n / 1024) + c
    end if

    -- Round(2) --

    n = bitOr(bitAnd(b, d), bitAnd(c, bitNot(d))) + a + x[i + 1] - 165796510
    if(n < 0) then
      a = bitOr(n * 32, bitOr((n + t_iWrap) / 134217728, 16)) + b
    else
      a = bitOr(n * 32, n / 134217728) + b
    end if

    n = bitOr(bitAnd(a, c), bitAnd(b, bitNot(c))) + d + x[i + 6] - 1069501632
    if(n < 0) then
      d = bitOr(n * 512, bitOr((n + t_iWrap) / 8388608, 256)) + a
    else
      d = bitOr(n * 512, n / 8388608) + a
    end if

    n = bitOr(bitAnd(d, b), bitAnd(a, bitNot(b))) + c + x[i + 11] + 643717713
    if(n < 0) then
      c = bitOr(n * 16384, bitOr((n + t_iWrap) / 262144, 8192)) + d
    else
      c = bitOr(n * 16384, n / 262144) + d
    end if

    n = bitOr(bitAnd(c, a), bitAnd(d, bitNot(a))) + b + x[i] - 373897302
    if(n < 0) then
      b = bitOr(n * 1048576, bitOr((n + t_iWrap) / 4096, 524288)) + c
    else
      b = bitOr(n * 1048576, n / 4096) + c
    end if

    n = bitOr(bitAnd(b, d), bitAnd(c, bitNot(d))) + a + x[i + 5] - 701558691
    if(n < 0) then
      a = bitOr(n * 32, bitOr((n + t_iWrap) / 134217728, 16)) + b
    else
      a = bitOr(n * 32, n / 134217728) + b
    end if

    n = bitOr(bitAnd(a, c), bitAnd(b, bitNot(c))) + d + x[i + 10] + 38016083
    if(n < 0) then
      d = bitOr(n * 512, bitOr((n + t_iWrap) / 8388608, 256)) + a
    else
      d = bitOr(n * 512, n / 8388608) + a
    end if

    n = bitOr(bitAnd(d, b), bitAnd(a, bitNot(b))) + c + x[i + 15] - 660478335
    if(n < 0) then
      c = bitOr(n * 16384, bitOr((n + t_iWrap) / 262144, 8192)) + d
    else
      c = bitOr(n * 16384, n / 262144) + d
    end if

    n = bitOr(bitAnd(c, a), bitAnd(d, bitNot(a))) + b + x[i + 4] - 405537848
    if(n < 0) then
      b = bitOr(n * 1048576, bitOr((n + t_iWrap) / 4096, 524288)) + c
    else
      b = bitOr(n * 1048576, n / 4096) + c
    end if

    n = bitOr(bitAnd(b, d), bitAnd(c, bitNot(d))) + a + x[i + 9] + 568446438
    if(n < 0) then
      a = bitOr(n * 32, bitOr((n + t_iWrap) / 134217728, 16)) + b
    else
      a = bitOr(n * 32, n / 134217728) + b
    end if

    n = bitOr(bitAnd(a, c), bitAnd(b, bitNot(c))) + d + x[i + 14] - 1019803690
    if(n < 0) then
      d = bitOr(n * 512, bitOr((n + t_iWrap) / 8388608, 256)) + a
    else
      d = bitOr(n * 512, n / 8388608) + a
    end if

    n = bitOr(bitAnd(d, b), bitAnd(a, bitNot(b))) + c + x[i + 3] - 187363961
    if(n < 0) then
      c = bitOr(n * 16384, bitOr((n + t_iWrap) / 262144, 8192)) + d
    else
      c = bitOr(n * 16384, n / 262144) + d
    end if

    n = bitOr(bitAnd(c, a), bitAnd(d, bitNot(a))) + b + x[i + 8] + 1163531501
    if(n < 0) then
      b = bitOr(n * 1048576, bitOr((n + t_iWrap) / 4096, 524288)) + c
    else
      b = bitOr(n * 1048576, n / 4096) + c
    end if

    n = bitOr(bitAnd(b, d), bitAnd(c, bitNot(d))) + a + x[i + 13] - 1444681467
    if(n < 0) then
      a = bitOr(n * 32, bitOr((n + t_iWrap) / 134217728, 16)) + b
    else
      a = bitOr(n * 32, n / 134217728) + b
    end if

    n = bitOr(bitAnd(a, c), bitAnd(b, bitNot(c))) + d + x[i + 2] - 51403784
    if(n < 0) then
      d = bitOr(n * 512, bitOr((n + t_iWrap) / 8388608, 256)) + a
    else
      d = bitOr(n * 512, n / 8388608) + a
    end if

    n = bitOr(bitAnd(d, b), bitAnd(a, bitNot(b))) + c + x[i + 7] + 1735328473
    if(n < 0) then
      c = bitOr(n * 16384, bitOr((n + t_iWrap) / 262144, 8192)) + d
    else
      c = bitOr(n * 16384, n / 262144) + d
    end if

    n = bitOr(bitAnd(c, a), bitAnd(d, bitNot(a))) + b + x[i + 12] - 1926607734
    if(n < 0) then
      b = bitOr(n * 1048576, bitOr((n + t_iWrap) / 4096, 524288)) + c
    else
      b = bitOr(n * 1048576, n / 4096) + c
    end if

    -- Round(3) --

    n = bitXor(bitXor(b, c), d) + a + x[i + 5] - 378558
    if(n < 0) then
      a = bitOr(n * 16, bitOr((n + t_iWrap) / 268435456, 8)) + b
    else
      a = bitOr(n * 16, n / 268435456) + b
    end if

    n = bitXor(bitXor(a, b), c) + d + x[i + 8] - 2022574463
    if(n < 0) then
      d = bitOr(n * 2048, bitOr((n + t_iWrap) / 2097152, 1024)) + a
    else
      d = bitOr(n * 2048, n / 2097152) + a
    end if

    n = bitXor(bitXor(d, a), b) + c + x[i + 11] + 1839030562
    if(n < 0) then
      c = bitOr(n * 65536, bitOr((n + t_iWrap) / 65536, 32768)) + d
    else
      c = bitOr(n * 65536, n / 65536) + d
    end if

    n = bitXor(bitXor(c, d), a) + b + x[i + 14] - 35309556
    if(n < 0) then
      b = bitOr(n * 8388608, bitOr((n + t_iWrap) / 512, 4194304)) + c
    else
      b = bitOr(n * 8388608, n / 512) + c
    end if

    n = bitXor(bitXor(b, c), d) + a + x[i + 1] - 1530992060
    if(n < 0) then
      a = bitOr(n * 16, bitOr((n + t_iWrap) / 268435456, 8)) + b
    else
      a = bitOr(n * 16, n / 268435456) + b
    end if

    n = bitXor(bitXor(a, b), c) + d + x[i + 4] + 1272893353
    if(n < 0) then
      d = bitOr(n * 2048, bitOr((n + t_iWrap) / 2097152, 1024)) + a
    else
      d = bitOr(n * 2048, n / 2097152) + a
    end if

    n = bitXor(bitXor(d, a), b) + c + x[i + 7] - 155497632
    if(n < 0) then
      c = bitOr(n * 65536, bitOr((n + t_iWrap) / 65536, 32768)) + d
    else
      c = bitOr(n * 65536, n / 65536) + d
    end if

    n = bitXor(bitXor(c, d), a) + b + x[i + 10] - 1094730640
    if(n < 0) then
      b = bitOr(n * 8388608, bitOr((n + t_iWrap) / 512, 4194304)) + c
    else
      b = bitOr(n * 8388608, n / 512) + c
    end if

    n = bitXor(bitXor(b, c), d) + a + x[i + 13] + 681279174
    if(n < 0) then
      a = bitOr(n * 16, bitOr((n + t_iWrap) / 268435456, 8)) + b
    else
      a = bitOr(n * 16, n / 268435456) + b
    end if

    n = bitXor(bitXor(a, b), c) + d + x[i] - 358537222
    if(n < 0) then
      d = bitOr(n * 2048, bitOr((n + t_iWrap) / 2097152, 1024)) + a
    else
      d = bitOr(n * 2048, n / 2097152) + a
    end if

    n = bitXor(bitXor(d, a), b) + c + x[i + 3] - 722521979
    if(n < 0) then
      c = bitOr(n * 65536, bitOr((n + t_iWrap) / 65536, 32768)) + d
    else
      c = bitOr(n * 65536, n / 65536) + d
    end if

    n = bitXor(bitXor(c, d), a) + b + x[i + 6] + 76029189
    if(n < 0) then
      b = bitOr(n * 8388608, bitOr((n + t_iWrap) / 512, 4194304)) + c
    else
      b = bitOr(n * 8388608, n / 512) + c
    end if

    n = bitXor(bitXor(b, c), d) + a + x[i + 9] - 640364487
    if(n < 0) then
      a = bitOr(n * 16, bitOr((n + t_iWrap) / 268435456, 8)) + b
    else
      a = bitOr(n * 16, n / 268435456) + b
    end if

    n = bitXor(bitXor(a, b), c) + d + x[i + 12] - 421815835
    if(n < 0) then
      d = bitOr(n * 2048, bitOr((n + t_iWrap) / 2097152, 1024)) + a
    else
      d = bitOr(n * 2048, n / 2097152) + a
    end if

    n = bitXor(bitXor(d, a), b) + c + x[i + 15] + 530742520
    if(n < 0) then
      c = bitOr(n * 65536, bitOr((n + t_iWrap) / 65536, 32768)) + d
    else
      c = bitOr(n * 65536, n / 65536) + d
    end if

    n = bitXor(bitXor(c, d), a) + b + x[i + 2] - 995338651
    if(n < 0) then
      b = bitOr(n * 8388608, bitOr((n + t_iWrap) / 512, 4194304)) + c
    else
      b = bitOr(n * 8388608, n / 512) + c
    end if

    -- Round(4) --

    n = bitXor(c, bitOr(b, bitNot(d))) + a + x[i] - 198630844
    if(n < 0) then
      a = bitOr(n * 64, bitOr((n + t_iWrap) / 67108864, 32)) + b
    else
      a = bitOr(n * 64, n / 67108864) + b
    end if

    n = bitXor(b, bitOr(a, bitNot(c))) + d + x[i + 7] + 1126891415
    if(n < 0) then
      d = bitOr(n * 1024, bitOr((n + t_iWrap) / 4194304, 512)) + a
    else
      d = bitOr(n * 1024, n / 4194304) + a
    end if

    n = bitXor(a, bitOr(d, bitNot(b))) + c + x[i + 14] - 1416354905
    if(n < 0) then
      c = bitOr(n * 32768, bitOr((n + t_iWrap) / 131072, 16384)) + d
    else
      c = bitOr(n * 32768, n / 131072) + d
    end if

    n = bitXor(d, bitOr(c, bitNot(a))) + b + x[i + 5] - 57434055
    if(n < 0) then
      b = bitOr(n * 2097152, bitOr((n + t_iWrap) / 2048, 1048576)) + c
    else
      b = bitOr(n * 2097152, n / 2048) + c
    end if

    n = bitXor(c, bitOr(b, bitNot(d))) + a + x[i + 12] + 1700485571
    if(n < 0) then
      a = bitOr(n * 64, bitOr((n + t_iWrap) / 67108864, 32)) + b
    else
      a = bitOr(n * 64, n / 67108864) + b
    end if

    n = bitXor(b, bitOr(a, bitNot(c))) + d + x[i + 3] - 1894986606
    if(n < 0) then
      d = bitOr(n * 1024, bitOr((n + t_iWrap) / 4194304, 512)) + a
    else
      d = bitOr(n * 1024, n / 4194304) + a
    end if

    n = bitXor(a, bitOr(d, bitNot(b))) + c + x[i + 10] - 1051523
    if(n < 0) then
      c = bitOr(n * 32768, bitOr((n + t_iWrap) / 131072, 16384)) + d
    else
      c = bitOr(n * 32768, n / 131072) + d
    end if

    n = bitXor(d, bitOr(c, bitNot(a))) + b + x[i + 1] - 2054922799
    if(n < 0) then
      b = bitOr(n * 2097152, bitOr((n + t_iWrap) / 2048, 1048576)) + c
    else
      b = bitOr(n * 2097152, n / 2048) + c
    end if

    n = bitXor(c, bitOr(b, bitNot(d))) + a + x[i + 8] + 1873313359
    if(n < 0) then
      a = bitOr(n * 64, bitOr((n + t_iWrap) / 67108864, 32)) + b
    else
      a = bitOr(n * 64, n / 67108864) + b
    end if

    n = bitXor(b, bitOr(a, bitNot(c))) + d + x[i + 15] - 30611744
    if(n < 0) then
      d = bitOr(n * 1024, bitOr((n + t_iWrap) / 4194304, 512)) + a
    else
      d = bitOr(n * 1024, n / 4194304) + a
    end if

    n = bitXor(a, bitOr(d, bitNot(b))) + c + x[i + 6] - 1560198380
    if(n < 0) then
      c = bitOr(n * 32768, bitOr((n + t_iWrap) / 131072, 16384)) + d
    else
      c = bitOr(n * 32768, n / 131072) + d
    end if

    n = bitXor(d, bitOr(c, bitNot(a))) + b + x[i + 13] + 1309151649
    if(n < 0) then
      b = bitOr(n * 2097152, bitOr((n + t_iWrap) / 2048, 1048576)) + c
    else
      b = bitOr(n * 2097152, n / 2048) + c
    end if

    n = bitXor(c, bitOr(b, bitNot(d))) + a + x[i + 4] - 145523070
    if(n < 0) then
      a = bitOr(n * 64, bitOr((n + t_iWrap) / 67108864, 32)) + b
    else
      a = bitOr(n * 64, n / 67108864) + b
    end if

    n = bitXor(b, bitOr(a, bitNot(c))) + d + x[i + 11] - 1120210379
    if(n < 0) then
      d = bitOr(n * 1024, bitOr((n + t_iWrap) / 4194304, 512)) + a
    else
      d = bitOr(n * 1024, n / 4194304) + a
    end if

    n = bitXor(a, bitOr(d, bitNot(b))) + c + x[i + 2] + 718787259
    if(n < 0) then
      c = bitOr(n * 32768, bitOr((n + t_iWrap) / 131072, 16384)) + d
    else
      c = bitOr(n * 32768, n / 131072) + d
    end if

    n = bitXor(d, bitOr(c, bitNot(a))) + b + x[i + 9] - 343485551
    if(n < 0) then
      b = bitOr(n * 2097152, bitOr((n + t_iWrap) / 2048, 1048576)) + c
    else
      b = bitOr(n * 2097152, n / 2048) + c
    end if

    a = a + olda
    b = b + oldb
    c = c + oldc
    d = d + oldd
    i = i + 16

  end repeat

  -- Construct 32 byte 'little-endian' hex string...

  t_sHex = "0123456789abcdef"
  t_iArr = [a, b, c, d]
  t_sOut = EMPTY

  repeat with i in t_iArr
    if(i > 0) then
      repeat with n = 1 to 4
        j = i mod 16
        i = i / 16
        k = i mod 16
        i = i / 16
        put char (k + 1) of t_sHex after t_sOut
        put char (j + 1) of t_sHex after t_sOut
      end repeat
    else
      i = bitNot(i)
      repeat with n = 1 to 4
        j = i mod 16
        i = i / 16
        k = i mod 16
        i = i / 16
        put char (16 - k) of t_sHex after t_sOut
        put char (16 - j) of t_sHex after t_sOut
      end repeat
    end if
  end repeat

  return(t_sOut)

end

--( end )-- -- -- -- -- -- -- -- -- -- -- -- -- --//
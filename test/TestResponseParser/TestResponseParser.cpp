// TestResponseParser.cpp : Defines the entry point for the console application.
//

#include "stdafx.h"
#include <boost/archive/detail/auto_link_archive.hpp>
#include <boost/archive/text_woarchive.hpp>
#include <boost/detail/lightweight_test.hpp>
#include <ResponseParser.h>
#include <WeaselUtility.h>
#include <sstream>
#include <string>

void test_1() {
  WCHAR resp[] = L"action=noop\n";
  DWORD len = static_cast<DWORD>(wcslen(resp));
  std::wstring commit;
  weasel::Context ctx;
  weasel::Status status;
  weasel::ResponseParser parser(&commit, &ctx, &status);
  parser(resp, len);
  BOOST_TEST(commit.empty());
  BOOST_TEST(ctx.empty());
}

void test_2() {
  WCHAR resp[] =
      L"action=commit\n"
      L"commit=教這句話上屏=3.14\n";
  DWORD len = static_cast<DWORD>(wcslen(resp));
  std::wstring commit;
  weasel::Context ctx;
  weasel::Status status;
  ctx.aux.str = L"從前的值";
  weasel::ResponseParser parser(&commit, &ctx, &status);
  parser(resp, len);
  BOOST_TEST(commit == L"教這句話上屏=3.14");
  BOOST_TEST(ctx.preedit.empty());
  BOOST_TEST(ctx.aux.str == L"從前的值");
  BOOST_TEST(ctx.cinfo.candies.empty());
}

void test_3() {
  WCHAR resp[] =
      L"action=ctx\n"
      L"ctx.preedit=寫作串=3.14\n"
      L"ctx.aux=sie'zuoh'chuan=3.14\n";
  DWORD len = static_cast<DWORD>(wcslen(resp));
  std::wstring commit;
  weasel::Context ctx;
  weasel::Status status;
  weasel::ResponseParser parser(&commit, &ctx, &status);
  parser(resp, len);
  BOOST_TEST(commit.empty());
  BOOST_TEST(ctx.preedit.str == L"寫作串=3.14");
  BOOST_TEST(ctx.preedit.attributes.empty());
  BOOST_TEST(ctx.aux.str == L"sie'zuoh'chuan=3.14");
}

void test_4() {
  weasel::CandidateInfo expected;
  expected.candies.emplace_back(L"候選甲");
  expected.candies.emplace_back(L"候選乙");
  expected.highlighted = 1;
  expected.currentPage = 0;
  expected.totalPages = 1;

  std::wstringstream archive;
  {
    boost::archive::text_woarchive oa(archive);
    oa << expected;
  }
  std::wstring resp =
      L"action=commit,ctx\n"
      L"ctx.preedit=候選乙=3.14\n"
      L"ctx.preedit.cursor=0,3\n"
      L"ctx.cand=" +
      archive.str() + L"\n";
  DWORD len = static_cast<DWORD>(resp.size());
  std::wstring commit;
  weasel::Context ctx;
  weasel::Status status;
  weasel::ResponseParser parser(&commit, &ctx, &status);
  parser(resp.data(), len);
  BOOST_TEST(commit.empty());
  BOOST_TEST(ctx.preedit.str == L"候選乙=3.14");
  BOOST_TEST_EQ(1U, ctx.preedit.attributes.size());
  if (ctx.preedit.attributes.size() != 1)
    return;
  weasel::TextAttribute attr0 = ctx.preedit.attributes[0];
  BOOST_TEST_EQ(weasel::HIGHLIGHTED, attr0.type);
  BOOST_TEST_EQ(0, attr0.range.start);
  BOOST_TEST_EQ(3, attr0.range.end);
  BOOST_TEST(ctx.aux.empty());
  weasel::CandidateInfo& c = ctx.cinfo;
  BOOST_TEST_EQ(2U, c.candies.size());
  if (c.candies.size() != 2)
    return;
  BOOST_TEST(c.candies[0].str == L"候選甲");
  BOOST_TEST(c.candies[1].str == L"候選乙");
  BOOST_TEST_EQ(1, c.highlighted);
  BOOST_TEST_EQ(0, c.currentPage);
  BOOST_TEST_EQ(1, c.totalPages);
}

void test_string_utilities() {
  const std::string utf8 = u8"小狼毫 AI";
  BOOST_TEST(wtou8(u8tow(utf8)) == utf8);

  const std::wstring original = L"line 1\nline 2\t\\done";
  BOOST_TEST(unescape_string(escape_string(original)) == original);
}

int _tmain(int argc, _TCHAR* argv[]) {
  test_1();
  test_2();
  test_3();
  test_4();
  test_string_utilities();

  return boost::report_errors();
}

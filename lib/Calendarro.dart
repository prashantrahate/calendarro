library calendarro;

import 'package:calendarro/CalendarroPage.dart';
import 'package:calendarro/DateUtils.dart';
import 'package:calendarro/DefaultDayTileBuilder.dart';
import 'package:flutter/material.dart';


abstract class DayTileBuilder {
  Widget build(BuildContext context, DateTime date);
}

enum DisplayMode { MONTHS, WEEKS }
enum SelectionMode { SINGLE, MULTI }

class Calendarro extends StatefulWidget {

  Calendarro(
      {Key key,
        this.startDate,
        this.endDate,
        this.displayMode = DisplayMode.WEEKS,
        this.dayTileBuilder,
        this.selectedDate,
        this.selectedDates,
        this.selectionMode = SelectionMode.SINGLE})
      : super(key: key) {

    startDate = DateUtils.toMidnight(startDate);
    endDate = DateUtils.toMidnight(endDate);

    if (dayTileBuilder == null) {
      dayTileBuilder = DefaultDayTileBuilder();
    }
  }

  DateTime selectedDate;
  List<DateTime> selectedDates = List();

  DateTime startDate;
  DateTime endDate;
  DisplayMode displayMode;
  SelectionMode selectionMode;

  CalendarroState state;
  DayTileBuilder dayTileBuilder;

  static CalendarroState of(BuildContext context) =>
      context.ancestorStateOfType(const TypeMatcher<CalendarroState>());

  @override
  CalendarroState createState() {
    state = CalendarroState(
        selectedDate: selectedDate,
        selectedDates: selectedDates);
    return state;
  }

  void setSelectedDate(DateTime date) {
    state.setSelectedDate(date);
  }

  void toggleDate(DateTime date) {
    state.toggleDate(date);
  }

  void setCurrentDate(DateTime date) {
    state.setCurrentDate(date);
  }

  int getPositionOfDate(DateTime date) {
    int daysDifference =
        date.difference(DateUtils.toMidnight(startDate)).inDays;
    int weekendsDifference = ((daysDifference + startDate.weekday) / 7).toInt();
    var position = daysDifference - weekendsDifference * 2;
    print("position: $position");
    return position;
  }

  int getPageForDate(DateTime date) {
    int daysDifference =
        date.difference(DateUtils.toMidnight(startDate)).inDays;
    int startDayOffset = startDate.weekday - DateTime.monday;
    int page = (daysDifference + startDayOffset) ~/ 7;
    return page;
  }
}

class CalendarroState extends State<Calendarro> {
  CalendarroState(
      {
        this.selectedDate,
        this.selectedDates});

  DateTime selectedDate;
  List<DateTime> selectedDates;

  int startDayOffset;
  int pagesCount;
  PageView pageView;

  @override
  void initState() {
    super.initState();

    if (selectedDate == null) {
      selectedDate = widget.startDate;
    }
  }

  void setSelectedDate(DateTime date) {
    setState(() {
      selectedDate = date;
    });
  }

  void setCurrentDate(DateTime date) {
    setState(() {
      int page = widget.getPageForDate(date);
      pageView.controller.jumpToPage(page);
    });
  }

  @override
  Widget build(BuildContext context) {
    int daysRange = widget.endDate.difference(widget.startDate).inDays;
    if (widget.displayMode == DisplayMode.WEEKS) {
      pagesCount = daysRange ~/ 7 + 1;
    } else {
      pagesCount = widget.endDate.month - widget.startDate.month + 1;
    }

    startDayOffset = widget.startDate.weekday - DateTime.monday;

    pageView = PageView.builder(
      itemBuilder: (context, position) => buildCalendarPage(position),
      itemCount: pagesCount,
      controller: PageController(
          initialPage:
          selectedDate != null ? widget.getPageForDate(selectedDate) : 0),
    );

    return Container(
        height: widget.displayMode == DisplayMode.WEEKS ? 60.0 : 320.0,
        child: pageView);
  }

  Widget buildCalendarPage(int position) {
    DateTime pageStartDate;
    DateTime pageEndDate;

    if (widget.displayMode == DisplayMode.WEEKS) {
      if (position == 0) {
        pageStartDate = widget.startDate;
        pageEndDate = widget.startDate.add(Duration(days: 6 - startDayOffset));
      } else if (position == pagesCount - 1) {
        pageStartDate =
            widget.startDate.add(Duration(days: 7 * position - startDayOffset));
        pageEndDate = widget.endDate;
      } else {
        pageStartDate =
            widget.startDate.add(Duration(days: 7 * position - startDayOffset));
        pageEndDate = widget.startDate
            .add(Duration(days: 7 * position + 6 - startDayOffset));
      }
    } else {
      if (position == 0) {
        pageStartDate = widget.startDate;
        DateTime nextMonthFirstDate =
        DateTime(widget.startDate.year, widget.startDate.month + 1, 1);
        pageEndDate = nextMonthFirstDate.subtract(Duration(days: 1));
      } else if (position == pagesCount - 1) {
        pageEndDate = widget.endDate;
        pageStartDate = DateTime(widget.endDate.year, widget.endDate.month, 1);
      } else {
        pageStartDate =
        DateTime(widget.startDate.year, widget.startDate.month + position, 1);
        DateTime nextMonthFirstDate =
        DateTime(widget.startDate.year, widget.startDate.month + position + 1, 1);
        pageEndDate = nextMonthFirstDate.subtract(Duration(days: 1));
      }
    }
    //DisplayMode == WEEKS

    return CalendarroPage(
        pageStartDate: pageStartDate, pageEndDate: pageEndDate);
  }

  bool isDateSelected(DateTime date) {
    if (widget.selectionMode == SelectionMode.MULTI) {
      return selectedDates.contains(date);
    } else {
      return DateUtils.isSameDay(selectedDate, date);
    }
  }

  void toggleDate(DateTime date) {
    setState(() {
      for (var i = selectedDates.length - 1; i >= 0; i--) {
        if (DateUtils.isSameDay(selectedDates[i], date)) {
          selectedDates.removeAt(i);
          return;
        }
      }

      selectedDates.add(date);
    });
  }

  void update() {
    setState(() {});
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../providers/counter_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final counter = ref.watch(counterProvider);
    
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(
          'Flutter Demo',
          style: TextStyle(fontSize: 20.sp),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              '您已经点击按钮次数:',
              style: TextStyle(fontSize: 16.sp),
            ),
            SizedBox(height: 20.h),
            Text(
              '$counter',
              style: TextStyle(
                fontSize: 32.sp,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
            SizedBox(height: 40.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () => ref.read(counterProvider.notifier).decrement(),
                  icon: Icon(Icons.remove, size: 20.sp),
                  label: Text('减少', style: TextStyle(fontSize: 14.sp)),
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(100.w, 40.h),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => ref.read(counterProvider.notifier).reset(),
                  icon: Icon(Icons.refresh, size: 20.sp),
                  label: Text('重置', style: TextStyle(fontSize: 14.sp)),
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(100.w, 40.h),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => ref.read(counterProvider.notifier).increment(),
        tooltip: '增加',
        child: Icon(Icons.add, size: 24.sp),
      ),
    );
  }
} 